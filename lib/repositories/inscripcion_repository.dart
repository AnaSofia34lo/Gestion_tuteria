import 'dart:async';

import 'package:gestion_tutorias/core/app_logger.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/local/inscripcion_local_data_source.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/remote/inscripcion_remote_data_source.dart';

/// Resultado de una ronda de sincronización, para mostrarlo en la UI.
class ResultadoSync {
  final int confirmadas;
  final int rechazadas;
  final int pendientes;
  const ResultadoSync({
    this.confirmadas = 0,
    this.rechazadas = 0,
    this.pendientes = 0,
  });
}

/// Local-first para solicitudes de inscripción:
/// 1. Valida reglas y guarda en Drift como SOLICITADA + pendingSync.
/// 2. La confirmación requiere conexión y la decide el servidor (atómica).
/// 3. Solo se marca sincronizada con respuesta remota satisfactoria.
class InscripcionRepository {
  final InscripcionLocalDataSource local;
  final InscripcionRemoteDataSource? remote;
  final Duration syncTimeout;
  final DateTime Function() reloj;
  Future<ResultadoSync>? _syncEnCurso;

  InscripcionRepository({
    required this.local,
    this.remote,
    this.syncTimeout = const Duration(seconds: 10),
    DateTime Function()? reloj,
  }) : reloj = reloj ?? DateTime.now;

  Future<List<Inscripcion>> misInscripciones(String uid) =>
      local.delEstudiante(uid);

  /// Funciona sin conexión. Devuelve la inscripción pendiente: mostrarla no
  /// equivale a tener la plaza garantizada.
  Future<Inscripcion> solicitar({
    required Sesion sesion,
    required String estudianteUid,
  }) async {
    final ahora = reloj();
    ReglasTutoria.validarSolicitud(
      sesion,
      estudianteUid: estudianteUid,
      inscripcionesDelEstudiante: await local.delEstudiante(estudianteUid),
      ahora: ahora,
    );
    final inscripcion = Inscripcion(
      id: Inscripcion.nuevoId(),
      sesionId: sesion.id,
      estudianteUid: estudianteUid,
      estado: EstadoInscripcion.solicitada,
      updatedAt: ahora,
    );
    await local.guardar(inscripcion);
    AppLogger.debug('Inscripción ${inscripcion.id} guardada localmente');
    return inscripcion;
  }

  /// Envía las solicitudes pendientes del usuario. Si ya hay un envío en
  /// curso, se reutiliza para no mandar la misma solicitud dos veces.
  Future<ResultadoSync> sincronizarPendientes(String uid) {
    return _syncEnCurso ??= _sincronizar(uid).whenComplete(() {
      _syncEnCurso = null;
    });
  }

  Future<ResultadoSync> _sincronizar(String uid) async {
    final remoteSource = remote;
    final pendientes = await local.pendientes(uid);
    if (remoteSource == null) {
      return ResultadoSync(pendientes: pendientes.length);
    }

    var confirmadas = 0;
    var rechazadas = 0;
    var siguenPendientes = 0;
    for (final inscripcion in pendientes) {
      try {
        final estado = await remoteSource
            .confirmar(inscripcion)
            .timeout(syncTimeout);
        final aplicada = await local.aplicarConfirmacion(inscripcion, estado);
        if (aplicada) {
          confirmadas++;
        } else {
          siguenPendientes++;
        }
      } on ReglaNegocioException catch (error) {
        // Rechazo definitivo: se conserva la evidencia y no se reenvía.
        await local.marcarRechazada(inscripcion, error.message);
        rechazadas++;
      } catch (error) {
        AppLogger.warning('Sync de inscripción pendiente: $error');
        await local.registrarFalloTemporal(
          inscripcion.id,
          'Sin confirmar. Reintenta cuando tengas conexión.',
        );
        siguenPendientes++;
      }
    }
    return ResultadoSync(
      confirmadas: confirmadas,
      rechazadas: rechazadas,
      pendientes: siguenPendientes,
    );
  }
}
