import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_tutorias/core/reglas_tutoria.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/remote/firestore_mapper.dart';

/// Única clase que conoce las sesiones en Firestore.
class SesionRemoteDataSource {
  final FirebaseFirestore firestore;
  SesionRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _sesiones =>
      firestore.collection('sesiones');

  List<Sesion> _mapear(QuerySnapshot<Map<String, dynamic>> snap) {
    final lista = snap.docs
        .map((d) => FirestoreMapper.sesion(d.id, d.data()))
        .toList();
    lista.sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  /// Escucha en tiempo real: los demás roles ven los cambios sin recargar.
  Stream<List<Sesion>> observarPorEstados(List<EstadoSesion> estados) =>
      _sesiones
          .where('estado', whereIn: estados.map((e) => e.name).toList())
          .snapshots()
          .map(_mapear);

  Stream<List<Sesion>> observarDelTutor(String tutorUid) =>
      _sesiones.where('tutorUid', isEqualTo: tutorUid).snapshots().map(_mapear);

  Stream<Sesion?> observar(String sesionId) => _sesiones
      .doc(sesionId)
      .snapshots()
      .map((d) => d.exists ? FirestoreMapper.sesion(d.id, d.data()!) : null);

  Future<List<Sesion>> publicadasDelTutor(String tutorUid) async {
    final snap = await _sesiones
        .where('tutorUid', isEqualTo: tutorUid)
        .where('estado', isEqualTo: EstadoSesion.publicada.name)
        .get(const GetOptions(source: Source.server));
    return _mapear(snap);
  }

  Future<void> crear(Sesion sesion) =>
      _sesiones.add(FirestoreMapper.nuevaSesion(sesion));

  /// Publica en una transacción que también crea `franjas/{tutor_inicio}`.
  /// Si la franja ya existe (otra sesión publicada del tutor a esa hora) la
  /// transacción falla: las reglas impiden sobrescribir una franja.
  Future<void> publicar(String sesionId, {required DateTime Function() reloj}) {
    return firestore.runTransaction((tx) async {
      final ref = _sesiones.doc(sesionId);
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw const ReglaNegocioException('La sesión ya no existe');
      }
      final sesion = FirestoreMapper.sesion(snap.id, snap.data()!);
      final franjaRef = firestore.collection('franjas').doc(sesion.claveFranja);
      final franja = await tx.get(franjaRef);
      if (franja.exists && franja.data()?['sesionId'] != sesion.id) {
        throw const ReglaNegocioException(
          'El tutor ya tiene una sesión publicada en esa franja',
        );
      }
      // Valida las demás condiciones de la regla 1 sobre el estado remoto.
      ReglasTutoria.publicar(
        sesion,
        sesionesDelTutor: const [],
        ahora: reloj(),
      );
      tx.set(franjaRef, {'tutorUid': sesion.tutorUid, 'sesionId': sesion.id});
      tx.update(ref, {
        'estado': EstadoSesion.publicada.name,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cambiarEstado(
    Sesion sesion,
    EstadoSesion estado, {
    String? motivo,
  }) => _sesiones.doc(sesion.id).update({
    'estado': estado.name,
    'actualizadoEn': FieldValue.serverTimestamp(),
    'motivoRechazo': ?motivo,
  });

  /// Lee el estado actual en el servidor antes de una transición.
  Future<Sesion> leerDelServidor(String sesionId) async {
    final snap = await _sesiones
        .doc(sesionId)
        .get(const GetOptions(source: Source.server));
    if (!snap.exists) {
      throw const ReglaNegocioException('La sesión ya no existe');
    }
    return FirestoreMapper.sesion(snap.id, snap.data()!);
  }
}
