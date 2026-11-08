# G61-5 · Tutorías académicas con cupos

Aplicación Flutter para gestionar sesiones de tutoría, aprobación de cupos y
control de asistencia. Proyecto final de Desarrollo Móvil, Universidad de
Medellín, semestre 2026-2.

| | |
|---|---|
| **Integrantes** | Edison Ospina Arroyave · Ana Sofía Londoño Ortega |
| **Caso** | G61-5 Tutorías académicas con cupos (pareja) |
| **Versión** | `1.0.0+1` (ver `pubspec.yaml`) |
| **Plataforma** | Android (APK release) |
| **Firebase** | Proyecto `gestion-tutorias-g61-5` |

## Roles

| Rol | Acciones en la app |
|---|---|
| **Estudiante** | Consulta sesiones publicadas, solicita inscripción (funciona sin conexión), cancela su cupo antes del inicio y consulta su asistencia en "Mis inscripciones". |
| **Tutor** | Propone sesiones (asignatura del catálogo, franja de 1 hora, capacidad 1-10), consulta inscritos, registra asistencia después del inicio y marca la sesión realizada. |
| **Coordinador académico** | Publica o rechaza propuestas y cierra sesiones realizadas cuando todos los inscritos tienen asistencia. |

Un usuario recién registrado siempre es **estudiante**. Los roles tutor y
coordinador se asignan desde Firebase Console (ver
[Asignar roles](#asignar-roles-de-prueba)). La app muestra solo las pestañas
del rol, y además las reglas de Firestore validan cada operación: ocultar un
botón no es la única protección.

## Cómo ejecutar

Requisitos: Flutter 3.44 o superior (Dart `^3.12.2`), Android SDK con un
emulador o dispositivo Android 7.0 (API 24) o superior.

```bash
flutter pub get
flutter run
```

El código generado de Drift (`lib/local/app_database.g.dart`) ya está en el
repositorio. Si se modifica una tabla:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### APK release

```bash
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Para
instalarlo en el emulador: `adb install -r build/app/outputs/flutter-apk/app-release.apk`.

**Firma:** el APK release se firma con la **clave de depuración** de Android
(`signingConfig = signingConfigs.getByName("debug")` en
`android/app/build.gradle.kts`). Es la firma aceptada para esta entrega
académica; no es una firma de producción ni sirve para publicar en una tienda.
Compilar en modo release (optimizado, sin `kDebugMode`) y firmar con clave de
producción son decisiones distintas.

### Pruebas

```bash
flutter test            # 52 pruebas: reglas, Drift, sincronización, HTTP, UI
```

Pruebas de las reglas de seguridad contra el emulador de Firestore (opcional,
requiere Node.js, Firebase CLI y Java 21+):

```bash
cd firestore_test
npm install
npm test                # 15 pruebas de firestore.rules
```

## Configuración de Firebase

El proyecto ya está configurado: `lib/firebase_options.dart`,
`android/app/google-services.json` y `firebase.json` se generaron con
`flutterfire configure`. Servicios usados:

- **Authentication** con correo y contraseña.
- **Cloud Firestore** (base `(default)`, ubicación `nam5`) con las reglas de
  `firestore.rules`.
- **Crashlytics** (plugin Gradle `com.google.firebase.crashlytics`).

Para desplegar cambios en las reglas:

```bash
firebase deploy --only firestore:rules --project gestion-tutorias-g61-5
```

Los archivos de configuración cliente (`google-services.json`,
`firebase_options.dart`) no son secretos: identifican el proyecto, y el acceso
lo controlan las reglas de Firestore. El repositorio no contiene contraseñas,
claves privadas ni credenciales de servicio.

### Asignar roles de prueba

1. Registrar cada cuenta desde la app (quedan como estudiante).
2. En Firebase Console → Firestore → colección `usuarios` → documento del uid
   de la cuenta, cambiar el campo `rol` a `tutor` o `coordinador`.
3. La app cambia de pestañas sola (escucha el perfil en tiempo real).

Las reglas impiden que un usuario cambie su propio rol desde la app. Las
cuentas de prueba se comparten solo por el medio privado que indique el
docente.

## Endpoint HTTP

Catálogo de asignaturas y temas (`id`, `nombre`, `area`, `descripcion`):

```
GET https://dummyjson.com/c/645c-94bf-42cf-a73a
```

El contenido de referencia está en `docs/catalogo_asignaturas.json` (9
registros). La URL se configura en `lib/core/api_config.dart`. El catálogo es
solo referencia: **capacidades y cupos viven en Firestore**, nunca en la
respuesta HTTP.

Manejo de errores: timeout (10 s), sin conexión, 404, 5xx, JSON inválido o con
campos faltantes y errores inesperados. Cada caso muestra un mensaje útil con
botón **Reintentar**. El Repository guarda la última respuesta en memoria para
no repetir peticiones al reconstruir widgets.

## Arquitectura

```
lib/
├── core/          reglas_tutoria.dart (reglas puras), logger, Crashlytics, formato
├── models/        Sesion, Inscripcion, Perfil, Asignatura
├── services/      AsignaturaService (HTTP + mapeo JSON)
├── local/         Drift: tabla inscripciones, AppDatabase, data source local
├── remote/        Firestore: sesiones, inscripciones (transacciones), mapper
├── repositories/  Auth, Asignatura, Sesion, Inscripcion (coordinan las fuentes)
├── screens/       login, home por rol, estudiante/, tutor/, coordinador/
└── widgets/       estados de carga/vacío/error, chips de estado, tarjetas
```

Las pantallas solo conocen los repositorios (por `AppScope`). Solo `remote/`
importa Firestore y solo `local/` importa Drift. Las reglas del negocio están
en `ReglasTutoria` como funciones puras: las usan el Repository antes de
escribir y la transacción de Firestore sobre el estado remoto.

## Modelo de datos

### Firestore

| Colección | Documento | Campos |
|---|---|---|
| `usuarios` | `{uid}` | `nombre`, `email`, `rol` (`estudiante` \| `tutor` \| `coordinador`), `creadoEn` |
| `sesiones` | auto | `asignaturaId`, `asignaturaNombre`, `tutorUid`, `tutorNombre`, `inicio` (Timestamp), `capacidad`, `cuposOcupados`, `estado`, `motivoRechazo?`, `actualizadoEn` |
| `inscripciones` | `{sesionId}_{estudianteUid}` | `sesionId`, `estudianteUid`, `estudianteNombre`, `tutorUid`, `asignaturaNombre`, `inicioSesion`, `estado`, `actualizadoEn` |
| `franjas` | `{tutorUid}_{inicioMillis}` | `tutorUid`, `sesionId` (reserva la franja al publicar) |

### Drift (SQLite local)

Tabla `inscripciones` (esquema v2): `id` (= id de Firestore), `sesionId`,
`estudianteUid` (dueño), `estudianteNombre`, `tutorUid`, `estado`,
`updatedAt`, `asignaturaNombre`, `inicioSesion`, `pendingSync`,
`ultimoError`.

### SharedPreferences

- `sesiones_solo_con_cupos`: filtro de la lista de sesiones del estudiante.
- `catalogo_area_filtro`: área seleccionada en el catálogo.

No se guardan contraseñas ni tokens en Drift, SharedPreferences ni logs.

## Estados y reglas del negocio

**Sesión:** `PROPUESTA → PUBLICADA → REALIZADA → CERRADA`. La coordinación
puede pasar una `PROPUESTA` a `RECHAZADA`. Rechazada y cerrada son
terminales.

**Inscripción:** `SOLICITADA → CONFIRMADA → ASISTIO | NO_ASISTIO`. El
estudiante puede `CANCELAR` antes del inicio. `RECHAZADA` = el servidor no la
confirmó (por ejemplo, sin cupo); queda guardada con el motivo.

| # | Regla | Dónde se valida |
|---|---|---|
| 1 | Solo se publica una sesión futura, en franja fija de una hora, con capacidad entre 1 y 10 y tutor asignado. Un tutor no publica dos sesiones en la misma franja. | `ReglasTutoria.publicar` + transacción que crea `franjas/{tutor_inicio}` (las reglas no permiten sobrescribirla). |
| 2 | No se confirma en una sesión no publicada o ya iniciada, ni se supera la capacidad. | `ReglasTutoria.confirmarCupo` dentro de la transacción + regla `cambioDeCupoValido`. |
| 3 | Un estudiante no tiene dos inscripciones activas en la misma sesión. Cancelar una confirmada antes del inicio libera la plaza. | Id determinista `sesionId_uid` + `validarSolicitud` + transacción de cancelación. |
| 4 | Solo el tutor registra asistencia, después del inicio. La coordinación cierra cuando la sesión terminó y todos los confirmados tienen asistencia. | `registrarAsistencia` y `cerrar` (relee inscritos del servidor) + reglas por rol. |

## Operación local-first

La operación sin conexión del caso es la **solicitud de inscripción**:

1. El estudiante toca "Solicitar cupo": se validan las reglas y se guarda en
   Drift como `SOLICITADA` con `pendingSync = true` y un id estable
   `sesionId_uid`.
2. "Mis inscripciones" muestra el estado del negocio y, aparte, el de
   sincronización ("Pendiente de envío"). Una solicitud pendiente **no** es una
   plaza garantizada, y la app lo indica.
3. Con conexión se envía en una transacción de Firestore que lee la sesión,
   valida la regla 2 y actualiza inscripción y `cuposOcupados` en el mismo
   paso. Si dos cuentas piden el último cupo, solo una obtiene la
   confirmación.
4. Se marca sincronizada solo tras la confirmación remota, y solo si el
   registro local no cambió mientras se enviaba.
5. Ante un fallo temporal queda pendiente con el motivo y se reintenta con el
   botón Sincronizar, al abrir "Mis inscripciones" o al iniciar sesión.
6. Si el servidor la rechaza (sin cupo, permisos) queda `RECHAZADA` con el
   motivo y deja de reenviarse. El usuario puede descartarla.

Cancelar una plaza **confirmada**, publicar, rechazar, registrar asistencia y
cerrar requieren conexión, porque consumen o liberan cupos, o son decisiones
de otro rol. Antes de cada transición se vuelve a leer el estado remoto.

Al cambiar de cuenta, Drift se filtra por el uid y solo se sincronizan los
pendientes de la cuenta activa.

## Crashlytics y privacidad

- Errores no capturados de Flutter y de la plataforma → fatales.
- Excepciones inesperadas (`AppLogger.error`) → no fatales.
- Rechazos de negocio, credenciales inválidas y fallos de red esperados se
  muestran en la interfaz y **no** se reportan.
- El botón "Enviar evento de prueba a Crashlytics" (pestaña Perfil) existe
  solo en modo debug (`kDebugMode`); no aparece en el APK release.

**Datos recolectados:** nombre, correo y rol (perfil), sesiones e
inscripciones con su asistencia. **Finalidad:** gestionar cupos y asistencia
de tutorías. **Acceso por rol:** cada estudiante ve sus inscripciones; el tutor
ve los inscritos de sus sesiones; la coordinación ve todas para aprobar y
cerrar. **Crashlytics** recibe trazas de error, modelo de dispositivo, versión
de la app, el uid como identificador y el rol. Nunca recibe correo,
contraseña ni tokens.

**Permisos Android:** solo `INTERNET`. No se usan cámara, ubicación,
micrófono ni almacenamiento externo.

## Límites conocidos

- Franjas fijas de una hora entre 07:00 y 21:00. Sin videollamadas, archivos,
  calificaciones institucionales ni integración con Moodle (fuera del alcance).
- Proponer, publicar, cerrar y registrar asistencia requieren conexión. Solo la
  solicitud de inscripción se puede crear sin conexión.
- La lista de sesiones sin conexión depende de la caché del SDK de Firestore
  (cargada previamente con sesión iniciada). La operación del caso
  (inscripción) sí se guarda explícitamente en Drift.
- La validación de "todos los confirmados con asistencia" al cerrar se hace en
  el Repository consultando el servidor. Las reglas de Firestore garantizan el
  rol y el estado `realizada`, pero no pueden recorrer la colección.
- Una sesión sin inscritos también debe marcarse realizada antes de cerrarse.

## Documentación de QA

- [docs/QA.md](docs/QA.md): matriz de pruebas, defectos y checklist de release.
- [docs/DATOS_PRUEBA.md](docs/DATOS_PRUEBA.md): cuentas por rol y operaciones
  para recorrer el flujo.
