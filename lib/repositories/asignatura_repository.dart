import 'package:gestion_tutorias/models/asignatura.dart';
import 'package:gestion_tutorias/services/asignatura_service.dart';

/// Coordina el acceso al catálogo para que la UI no conozca la fuente.
///
/// Guarda en memoria la última respuesta exitosa: así una reconstrucción de
/// widgets no repite la petición y solo [refrescar] vuelve a ir a la red.
class AsignaturaRepository {
  final AsignaturaService service;
  List<Asignatura>? _cache;
  Future<List<Asignatura>>? _enCurso;

  AsignaturaRepository(this.service);

  Future<List<Asignatura>> getAsignaturas() {
    final cache = _cache;
    if (cache != null) return Future.value(cache);
    return _cargar();
  }

  Future<List<Asignatura>> refrescar() {
    _cache = null;
    return _cargar();
  }

  /// Si dos pantallas piden el catálogo a la vez, comparten la misma petición.
  Future<List<Asignatura>> _cargar() {
    return _enCurso ??= service
        .getAsignaturas()
        .then((items) => _cache = items)
        .whenComplete(() => _enCurso = null);
  }

  List<String> areas(List<Asignatura> asignaturas) {
    final areas = asignaturas.map((a) => a.area).toSet().toList()..sort();
    return areas;
  }

  List<Asignatura> filtrarPorArea(List<Asignatura> asignaturas, String? area) {
    if (area == null) return asignaturas;
    return asignaturas.where((a) => a.area == area).toList();
  }
}
