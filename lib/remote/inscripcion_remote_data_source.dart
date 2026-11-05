import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';

/// Contrato de la fuente remota de inscripciones.
///
/// La implementación con Firestore debe confirmar dentro de una transacción:
/// leer la sesión, aplicar `ReglasTutoria.confirmarCupo` sobre ese estado
/// remoto y escribir en el mismo paso la inscripción (doc con `id` estable,
/// para que un reintento no duplique) y el contador `cuposOcupados`.
///
/// Debe lanzar `ReglaNegocioException` si el servidor rechaza la solicitud
/// (sin cupo, sesión iniciada...) y cualquier otra excepción ante fallos
/// temporales de red.
abstract class InscripcionRemoteDataSource {
  Future<Sesion> obtenerSesion(String sesionId);

  Future<EstadoInscripcion> confirmar(Inscripcion inscripcion);
}
