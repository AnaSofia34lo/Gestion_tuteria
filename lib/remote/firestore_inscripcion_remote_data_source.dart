import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/remote/firestore_mapper.dart';
import 'package:gestion_tutorias/remote/inscripcion_remote_data_source.dart';

/// Única clase que conoce las inscripciones en Firestore.
///
/// La confirmación y la cancelación usan transacciones: se lee la sesión,
/// se valida la regla sobre ese estado remoto y se escriben inscripción y
/// contador `cuposOcupados` en el mismo paso. Si dos estudiantes piden el
/// último cupo, Firestore reintenta la segunda transacción con el contador
/// actualizado y la regla la rechaza.
class FirestoreInscripcionRemoteDataSource
    implements InscripcionRemoteDataSource {
  final FirebaseFirestore firestore;
  final DateTime Function() reloj;

  FirestoreInscripcionRemoteDataSource(
    this.firestore, {
    DateTime Function()? reloj,
  }) : reloj = reloj ?? DateTime.now;

  CollectionReference<Map<String, dynamic>> get _sesiones =>
      firestore.collection('sesiones');
  CollectionReference<Map<String, dynamic>> get _inscripciones =>
      firestore.collection('inscripciones');

  /// Un rechazo de las reglas de seguridad es definitivo: se convierte en
  /// regla de negocio para no reenviarlo indefinidamente.
  Future<T> _rechazoDefinitivo<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const ReglaNegocioException(
          'El servidor rechazó la operación (permisos o estado de la sesión)',
        );
      }
      rethrow;
    }
  }

  @override
  Future<EstadoInscripcion> confirmar(Inscripcion inscripcion) {
    return _rechazoDefinitivo(() => _confirmar(inscripcion));
  }

  Future<EstadoInscripcion> _confirmar(Inscripcion inscripcion) {
    return firestore.runTransaction((tx) async {
      final sesionRef = _sesiones.doc(inscripcion.sesionId);
      final inscripcionRef = _inscripciones.doc(inscripcion.id);
      final sesionSnap = await tx.get(sesionRef);
      final inscripcionSnap = await tx.get(inscripcionRef);

      if (!sesionSnap.exists) {
        throw const ReglaNegocioException('La sesión ya no existe');
      }
      final sesion = FirestoreMapper.sesion(sesionSnap.id, sesionSnap.data()!);

      if (inscripcionSnap.exists) {
        final actual = FirestoreMapper.inscripcion(
          inscripcionSnap.id,
          inscripcionSnap.data()!,
        );
        // Reintento de algo ya aplicado: idempotente, no consume otro cupo.
        if (actual.estado != EstadoInscripcion.cancelada) return actual.estado;
      }

      final actualizada = ReglasTutoria.confirmarCupo(sesion, ahora: reloj());
      tx.set(
        inscripcionRef,
        FirestoreMapper.inscripcionRemota(
          inscripcion,
          EstadoInscripcion.confirmada,
          sesion,
        ),
      );
      tx.update(sesionRef, {'cuposOcupados': actualizada.cuposOcupados});
      return EstadoInscripcion.confirmada;
    });
  }

  @override
  Future<void> cancelar(Inscripcion inscripcion) {
    return _rechazoDefinitivo(() => _cancelar(inscripcion));
  }

  Future<void> _cancelar(Inscripcion inscripcion) {
    return firestore.runTransaction((tx) async {
      final sesionRef = _sesiones.doc(inscripcion.sesionId);
      final inscripcionRef = _inscripciones.doc(inscripcion.id);
      final sesionSnap = await tx.get(sesionRef);
      final inscripcionSnap = await tx.get(inscripcionRef);
      if (!sesionSnap.exists || !inscripcionSnap.exists) {
        throw const ReglaNegocioException('La inscripción ya no existe');
      }
      final sesion = FirestoreMapper.sesion(sesionSnap.id, sesionSnap.data()!);
      final actual = FirestoreMapper.inscripcion(
        inscripcionSnap.id,
        inscripcionSnap.data()!,
      );
      // Se valida con el estado remoto, no con la copia local.
      final r = ReglasTutoria.cancelar(actual, sesion, ahora: reloj());
      tx.update(inscripcionRef, {
        'estado': EstadoInscripcion.cancelada.name,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      if (r.sesion.cuposOcupados != sesion.cuposOcupados) {
        tx.update(sesionRef, {'cuposOcupados': r.sesion.cuposOcupados});
      }
    });
  }

  @override
  Future<List<Inscripcion>> delEstudiante(String estudianteUid) async {
    final snap = await _inscripciones
        .where('estudianteUid', isEqualTo: estudianteUid)
        .get();
    return snap.docs
        .map((d) => FirestoreMapper.inscripcion(d.id, d.data()))
        .toList();
  }

  /// La consulta filtra por `tutorUid` para cumplir las reglas de lectura:
  /// el tutor solo ve inscritos de sus propias sesiones.
  Query<Map<String, dynamic>> _deSesion(
    Sesion sesion, {
    bool comoTutor = true,
  }) {
    var query = _inscripciones.where('sesionId', isEqualTo: sesion.id);
    if (comoTutor) query = query.where('tutorUid', isEqualTo: sesion.tutorUid);
    return query;
  }

  List<Inscripcion> _mapear(QuerySnapshot<Map<String, dynamic>> snap) {
    final lista = snap.docs
        .map((d) => FirestoreMapper.inscripcion(d.id, d.data()))
        .toList();
    lista.sort((a, b) => a.estudianteNombre.compareTo(b.estudianteNombre));
    return lista;
  }

  @override
  Stream<List<Inscripcion>> observarInscritos(Sesion sesion) =>
      _deSesion(sesion).snapshots().map(_mapear);

  @override
  Future<List<Inscripcion>> inscritos(Sesion sesion) async => _mapear(
    await _deSesion(sesion).get(const GetOptions(source: Source.server)),
  );

  @override
  Future<void> registrarAsistencia(Inscripcion inscripcion) =>
      _rechazoDefinitivo(
        () => _inscripciones.doc(inscripcion.id).update({
          'estado': inscripcion.estado.name,
          'actualizadoEn': FieldValue.serverTimestamp(),
        }),
      );
}
