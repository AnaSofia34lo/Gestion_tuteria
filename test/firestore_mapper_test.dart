import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/remote/firestore_mapper.dart';

void main() {
  group('Mapeo Firestore', () {
    final inicio = DateTime(2026, 11, 20, 14);

    test('sesión desde documento con Timestamp', () {
      final s = FirestoreMapper.sesion('s1', {
        'asignaturaId': 8,
        'asignaturaNombre': 'Desarrollo móvil',
        'tutorUid': 't1',
        'tutorNombre': 'Tutor',
        'inicio': Timestamp.fromDate(inicio),
        'capacidad': 4,
        'cuposOcupados': 1,
        'estado': 'publicada',
      });
      expect(s.id, 's1');
      expect(s.asignaturaId, '8');
      expect(s.inicio, inicio);
      expect(s.cuposDisponibles, 3);
      expect(s.estado, EstadoSesion.publicada);
      expect(s.claveFranja, 't1_${inicio.millisecondsSinceEpoch}');
    });

    test('la propuesta nueva siempre nace sin cupos ocupados', () {
      final datos = FirestoreMapper.nuevaSesion(
        Sesion(
          id: '',
          asignaturaId: '8',
          tutorUid: 't1',
          inicio: inicio,
          capacidad: 5,
          cuposOcupados: 3,
          estado: EstadoSesion.publicada,
        ),
      );
      expect(datos['cuposOcupados'], 0);
      expect(datos['estado'], 'propuesta');
    });

    test('la inscripción remota no lleva datos de sincronización local', () {
      final i = Inscripcion(
        id: Inscripcion.idPara('s1', 'e1'),
        sesionId: 's1',
        estudianteUid: 'e1',
        estado: EstadoInscripcion.solicitada,
        updatedAt: inicio,
        ultimoError: 'x',
      );
      final datos = FirestoreMapper.inscripcionRemota(
        i,
        EstadoInscripcion.confirmada,
        Sesion(
          id: 's1',
          asignaturaId: '8',
          tutorUid: 't1',
          inicio: inicio,
          capacidad: 2,
        ),
      );
      expect(datos.containsKey('pendingSync'), isFalse);
      expect(datos.containsKey('ultimoError'), isFalse);
      expect(datos['estado'], 'confirmada');
      expect(datos['tutorUid'], 't1');
    });
  });
}
