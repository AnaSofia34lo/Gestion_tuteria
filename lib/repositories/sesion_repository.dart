import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_tutorias/core/app_logger.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/models/asignatura.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/remote/sesion_remote_data_source.dart';
import 'package:gestion_tutorias/repositories/inscripcion_repository.dart';

/// Coordina las sesiones (Firestore) con las reglas del dominio. Antes de
/// cada transición vuelve a leer el estado remoto: un dato viejo en pantalla
/// no autoriza la operación.
class SesionRepository {
  final SesionRemoteDataSource remote;
  final InscripcionRepository inscripciones;
  final DateTime Function() reloj;
  final Duration timeout;

  SesionRepository({
    required this.remote,
    required this.inscripciones,
    DateTime Function()? reloj,
    this.timeout = const Duration(seconds: 10),
  }) : reloj = reloj ?? DateTime.now;

  /// Estudiantes: sesiones publicadas que aún no inician.
  Stream<List<Sesion>> observarDisponibles() => remote
      .observarPorEstados(const [EstadoSesion.publicada])
      .map((lista) => lista.where((s) => !s.haIniciado(reloj())).toList());

  Stream<List<Sesion>> observarDelTutor(String tutorUid) =>
      remote.observarDelTutor(tutorUid);

  /// Coordinación: propuestas por revisar y sesiones realizadas por cerrar.
  Stream<List<Sesion>> observarParaCoordinacion() => remote.observarPorEstados(
    const [EstadoSesion.propuesta, EstadoSesion.realizada],
  );

  Stream<Sesion?> observar(String sesionId) => remote.observar(sesionId);

  Future<void> proponer({
    required Perfil tutor,
    required Asignatura asignatura,
    required DateTime inicio,
    required int capacidad,
  }) async {
    if (tutor.rol != Rol.tutor) {
      throw const ReglaNegocioException('Solo un tutor crea sesiones');
    }
    final sesion = Sesion(
      id: '',
      asignaturaId: asignatura.id,
      asignaturaNombre: asignatura.nombre,
      tutorUid: tutor.uid,
      tutorNombre: tutor.nombre,
      inicio: inicio,
      capacidad: capacidad,
    );
    ReglasTutoria.validarPropuesta(sesion, ahora: reloj());
    await _remoto(() => remote.crear(sesion));
  }

  Future<void> publicar(Sesion sesion, Perfil actor) async {
    _exigirRol(actor, Rol.coordinador);
    await _remoto(() => remote.publicar(sesion.id, reloj: reloj));
  }

  Future<void> rechazar(Sesion sesion, Perfil actor, String motivo) async {
    _exigirRol(actor, Rol.coordinador);
    await _remoto(() async {
      final actual = await remote.leerDelServidor(sesion.id);
      ReglasTutoria.rechazar(actual);
      await remote.cambiarEstado(
        actual,
        EstadoSesion.rechazada,
        motivo: motivo.trim().isEmpty ? 'Sin motivo' : motivo.trim(),
      );
    });
  }

  Future<void> marcarRealizada(Sesion sesion, Perfil tutor) async {
    _exigirRol(tutor, Rol.tutor);
    await _remoto(() async {
      final actual = await remote.leerDelServidor(sesion.id);
      ReglasTutoria.marcarRealizada(
        actual,
        actorUid: tutor.uid,
        ahora: reloj(),
      );
      await remote.cambiarEstado(actual, EstadoSesion.realizada);
    });
  }

  /// Regla 4: se consulta la asistencia en el servidor antes de cerrar.
  Future<void> cerrar(Sesion sesion, Perfil actor) async {
    _exigirRol(actor, Rol.coordinador);
    await _remoto(() async {
      final actual = await remote.leerDelServidor(sesion.id);
      final inscritos = await inscripciones.inscritosDelServidor(actual);
      ReglasTutoria.cerrar(actual, inscripciones: inscritos, ahora: reloj());
      await remote.cambiarEstado(actual, EstadoSesion.cerrada);
    });
  }

  void _exigirRol(Perfil actor, Rol rol) {
    if (actor.rol != rol) {
      throw ReglaNegocioException('Acción permitida solo para ${rol.etiqueta}');
    }
  }

  /// Traduce errores remotos: reglas de negocio pasan tal cual; permisos y
  /// red se muestran con mensajes útiles; lo inesperado va a Crashlytics.
  Future<void> _remoto(Future<void> Function() accion) async {
    try {
      await accion().timeout(timeout);
    } on ReglaNegocioException {
      rethrow;
    } on FirebaseException catch (e, s) {
      if (e.code == 'permission-denied') {
        AppLogger.warning('Firestore negó la operación');
        throw const ReglaNegocioException(
          'El servidor rechazó la operación para tu rol o estado actual',
        );
      }
      if (e.code == 'unavailable') {
        throw const ReglaNegocioException(
          'Sin conexión. La operación requiere Internet',
        );
      }
      AppLogger.error('Error de Firestore', e, s);
      throw const ReglaNegocioException('No se pudo completar la operación');
    } on TimeoutException {
      throw const ReglaNegocioException(
        'El servidor tardó demasiado. Revisa tu conexión',
      );
    }
  }
}
