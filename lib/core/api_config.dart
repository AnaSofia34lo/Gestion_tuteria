/// Endpoint HTTP del catálogo de asignaturas y temas.
///
/// Subir `docs/catalogo_asignaturas.json` a MockAPI, dummyjson.com/c o un
/// endpoint propio y reemplazar esta URL por la que entregue el servicio.
class ApiConfig {
  ApiConfig._();

  static const catalogoUrl = 'https://dummyjson.com/c/REEMPLAZAR-ID-CATALOGO';
  static const timeout = Duration(seconds: 10);
}
