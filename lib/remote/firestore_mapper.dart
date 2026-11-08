import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';

/// Conversión entre documentos de Firestore y modelos del dominio. Mantiene
/// los modelos libres de dependencias de Firebase.
class FirestoreMapper {
  FirestoreMapper._();

  static DateTime _fecha(Object? valor) => switch (valor) {
    Timestamp t => t.toDate(),
    DateTime d => d,
    _ => DateTime.fromMillisecondsSinceEpoch(0),
  };

  static Sesion sesion(String id, Map<String, dynamic> d) => Sesion(
    id: id,
    asignaturaId: (d['asignaturaId'] ?? '').toString(),
    asignaturaNombre: (d['asignaturaNombre'] as String?) ?? '',
    tutorUid: (d['tutorUid'] as String?) ?? '',
    tutorNombre: (d['tutorNombre'] as String?) ?? '',
    inicio: _fecha(d['inicio']),
    capacidad: (d['capacidad'] as num?)?.toInt() ?? 0,
    cuposOcupados: (d['cuposOcupados'] as num?)?.toInt() ?? 0,
    estado: EstadoSesion.fromName((d['estado'] as String?) ?? 'propuesta'),
    motivoRechazo: d['motivoRechazo'] as String?,
  );

  static Map<String, dynamic> nuevaSesion(Sesion s) => {
    'asignaturaId': s.asignaturaId,
    'asignaturaNombre': s.asignaturaNombre,
    'tutorUid': s.tutorUid,
    'tutorNombre': s.tutorNombre,
    'inicio': Timestamp.fromDate(s.inicio),
    'capacidad': s.capacidad,
    'cuposOcupados': 0,
    'estado': EstadoSesion.propuesta.name,
    'actualizadoEn': FieldValue.serverTimestamp(),
  };

  static Inscripcion inscripcion(String id, Map<String, dynamic> d) =>
      Inscripcion(
        id: id,
        sesionId: (d['sesionId'] as String?) ?? '',
        estudianteUid: (d['estudianteUid'] as String?) ?? '',
        estudianteNombre: (d['estudianteNombre'] as String?) ?? '',
        tutorUid: (d['tutorUid'] as String?) ?? '',
        estado: EstadoInscripcion.fromName(
          (d['estado'] as String?) ?? 'confirmada',
        ),
        updatedAt: _fecha(d['actualizadoEn']),
        asignaturaNombre: (d['asignaturaNombre'] as String?) ?? '',
        inicioSesion: d['inicioSesion'] == null
            ? null
            : _fecha(d['inicioSesion']),
        pendingSync: false,
      );

  /// pendingSync y ultimoError son estado local: no viajan a Firestore.
  static Map<String, dynamic> inscripcionRemota(
    Inscripcion i,
    EstadoInscripcion estado,
    Sesion sesion,
  ) => {
    'sesionId': i.sesionId,
    'estudianteUid': i.estudianteUid,
    'estudianteNombre': i.estudianteNombre,
    'tutorUid': sesion.tutorUid,
    'asignaturaNombre': sesion.asignaturaNombre,
    'inicioSesion': Timestamp.fromDate(sesion.inicio),
    'estado': estado.name,
    'actualizadoEn': FieldValue.serverTimestamp(),
  };
}
