import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';

/// Contrato de la fuente remota de inscripciones. La implementación real es
/// [FirestoreInscripcionRemoteDataSource]; las pruebas usan un doble en
/// memoria con el mismo comportamiento atómico.
///
/// Los métodos lanzan `ReglaNegocioException` si el servidor rechaza la
/// operación (sin cupo, sesión iniciada...) y cualquier otra excepción ante
/// fallos temporales de red.
abstract class InscripcionRemoteDataSource {
  /// Confirma de forma atómica inscripción + cupo, validando la regla sobre
  /// el estado remoto de la sesión. Reintentar algo ya confirmado devuelve
  /// el mismo estado sin consumir otro cupo.
  Future<EstadoInscripcion> confirmar(Inscripcion inscripcion);

  /// Cancela una inscripción confirmada y libera el cupo en el mismo paso.
  Future<void> cancelar(Inscripcion inscripcion);

  /// Inscripciones del estudiante guardadas en Firestore.
  Future<List<Inscripcion>> delEstudiante(String estudianteUid);

  /// Inscritos de una sesión, para el tutor y la coordinación.
  Stream<List<Inscripcion>> observarInscritos(Sesion sesion);

  /// Lectura puntual de los inscritos (cierre de coordinación).
  Future<List<Inscripcion>> inscritos(Sesion sesion);

  Future<void> registrarAsistencia(Inscripcion inscripcion);
}
