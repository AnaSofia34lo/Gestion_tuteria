# QA · G61-5 Tutorías académicas con cupos

**Versión probada:** `1.0.0+1` · **Proyecto Firebase:** `gestion-tutorias-g61-5`

Hay dos tipos de evidencia:

- **Automatizada:** se ejecuta con `flutter test` (52 pruebas) y con
  `cd firestore_test && npm test` (15 pruebas de reglas contra el emulador de
  Firestore). Estas filas se marcan con el resultado real de la última
  ejecución.
- **Manual en APK:** se ejecuta sobre el APK release en el emulador Android.
  Hasta que el equipo las ejecute quedan como **Por ejecutar**. No se marca
  como aprobado un escenario que no se ha corrido.

## Matriz de pruebas

| ID | Precondición | Cuenta / rol | Pasos | Resultado esperado | Resultado obtenido | Estado | Versión | Evidencia |
|---|---|---|---|---|---|---|---|---|
| QA-01 | App instalada, sin sesión | Nueva | Registrarse con nombre, correo y contraseña de 6+ caracteres | Entra como Estudiante y ve las pestañas Sesiones, Mis inscripciones, Catálogo y Perfil | | Por ejecutar | 1.0.0+1 | Captura |
| QA-02 | Cuenta existente | Estudiante | Iniciar sesión con contraseña incorrecta; luego con correo mal escrito | "Correo o contraseña incorrectos" / "El correo no es válido". El botón se bloquea mientras envía | Mensajes verificados en `auth_y_firestore_test.dart` | Aprobado (automatizado) · UI por ejecutar | 1.0.0+1 | Prueba + captura |
| QA-03 | Sesión iniciada | Estudiante | Intentar cambiar su `rol` o crear una sesión | Firestore lo rechaza; la app no muestra opciones de tutor ni de coordinación | Reglas rechazan (`firestore_test`: "nadie puede cambiar su propio rol", "solo un tutor propone") | Aprobado (automatizado) | 1.0.0+1 | `npm test` |
| QA-04 | Inscripción de est1 confirmada | Estudiante est2 / Tutor 2 | Leer la inscripción de otra cuenta | Lectura rechazada; el tutor solo ve inscritos de sus sesiones | `firestore_test`: "el estudiante solo lee sus inscripciones…" | Aprobado (automatizado) | 1.0.0+1 | `npm test` |
| QA-05 | est1 con solicitud pendiente | est1 → est2 | Cerrar sesión con est1, entrar con est2 y sincronizar | est2 no ve ni envía los pendientes de est1 | `inscripcion_repository_test`: "solo sincroniza pendientes de la cuenta actual" | Aprobado (automatizado) · APK por ejecutar | 1.0.0+1 | Prueba |
| QA-06 | Internet activo | Cualquiera | Abrir Catálogo | Lista de 9 asignaturas con filtro por área | Captura del catálogo cargando desde dummyjson (sprint de avances) | Aprobado | 1.0.0+1 | Captura `1_catalogo.png` |
| QA-07 | Respuesta 500 / JSON inválido / lista vacía / sin red | — | Simular cada caso | Mensaje útil + "Reintentar"; vacío muestra estado vacío; el reintento recupera | `asignatura_service_test` y `widget_test` | Aprobado (automatizado) | 1.0.0+1 | Prueba |
| QA-08 | Sesión publicada cargada | Estudiante | Modo avión → Solicitar cupo → cerrar y abrir la app | La solicitud sigue en "Mis inscripciones" como Solicitada + "Pendiente de envío" | Persistencia tras reabrir SQLite verificada en prueba | Aprobado (automatizado) · APK por ejecutar | 1.0.0+1 | Prueba + captura |
| QA-09 | QA-08 hecho | Estudiante | Quitar modo avión → Sincronizar dos veces | Queda Confirmada y Sincronizada; el cupo sube 1 una sola vez | "fallo temporal conserva el pendiente y el reintento no duplica" | Aprobado (automatizado) · APK por ejecutar | 1.0.0+1 | Prueba + captura |
| QA-10 | Propuesta en estado propuesta | Coordinador | Intentar cerrarla; publicar otra del mismo tutor en la misma franja | "No puede pasar a cerrada" / "ya tiene una sesión publicada en esa franja" | `reglas_tutoria_test` + `firestore_test` (franja) | Aprobado (automatizado) | 1.0.0+1 | Prueba |
| QA-11 | Sesión con capacidad 1 | est1 y est2 | **Escenario 1:** ambos solicitan el último cupo y sincronizan | Solo uno queda Confirmada; el otro Rechazada "No quedan cupos" | Repository (doble en memoria) + emulador con transacciones concurrentes: 1 de 2 exitosas | Aprobado (automatizado) · APK por ejecutar | 1.0.0+1 | `npm test` + captura |
| QA-12 | est1 confirmada, antes del inicio | Estudiante + Tutor | **Escenario 2:** cancelar; el tutor revisa inscritos | Cupo liberado; est1 no aparece como asistente ni se le puede marcar | "escenario 2: cancelar libera el cupo…" (app y reglas) | Aprobado (automatizado) · APK por ejecutar | 1.0.0+1 | Prueba + captura |
| QA-13 | Sesión realizada con un confirmado sin asistencia | Coordinador | **Escenario 3:** intentar cerrar | Bloqueado: "Faltan 1 inscrito(s) por registrar asistencia" | `reglas_tutoria_test`: escenario 3 | Aprobado (automatizado) · APK por ejecutar | 1.0.0+1 | Prueba + captura |
| QA-14 | Sesión iniciada con inscritos | Tutor 2 (no dueño) | Registrar asistencia | Rechazado; solo el tutor dueño puede | `firestore_test`: "solo el tutor de la sesión registra asistencia" | Aprobado (automatizado) | 1.0.0+1 | `npm test` |
| QA-15 | Build debug | Cualquiera | Perfil → "Enviar evento de prueba a Crashlytics" | El evento aparece en Firebase Console → Crashlytics con versión y dispositivo | | Por ejecutar | 1.0.0+1 | Captura de la consola |
| QA-16 | APK release instalado | Los tres roles | Recorrido completo: proponer → publicar → inscribir → asistencia → realizada → cerrar | Todo el flujo funciona; en release no aparece el botón de prueba de Crashlytics | | Por ejecutar | 1.0.0+1 | Capturas |

## Registro de defectos

| ID | Descripción | Hallado en | Corrección | Estado |
|---|---|---|---|---|
| D-01 | Las pruebas HTTP fallaban con tildes (`Cálculo`) porque la respuesta simulada se codificaba en Latin-1 | `flutter test` | Las respuestas de prueba se envían en UTF-8, como una API real | Corregido |
| D-02 | La transacción de confirmación leía la inscripción antes de que existiera y la regla de lectura fallaba con `resource == null`: nadie podía confirmar un cupo | `firestore_test` (emulador) | La regla de lectura permite leer un documento inexistente cuyo id termina en el uid del estudiante | Corregido y desplegado |
| D-03 | Con `asyncExpand`, el perfil nunca terminaba de escucharse y el cierre de sesión no se reflejaba | Revisión de código | Escucha manual que cancela el perfil anterior al cambiar de cuenta | Corregido |
| D-04 | Cerrar una sesión `publicada` iba directo a `cerrada`, sin pasar por `realizada` | Revisión contra la ficha del caso | Transición `publicada → realizada → cerrada`; el tutor marca realizada al terminar | Corregido |

## Checklist de release

- [x] Autenticación con correo y contraseña implementada, con mensajes de error y bloqueo de envíos repetidos.
- [x] Tres roles con pestañas propias; las reglas de Firestore están desplegadas y probadas en el emulador (15/15).
- [x] Reglas de negocio 1-4 y escenarios 1-3 validados en pruebas automatizadas.
- [x] Drift: solicitud offline, persistencia tras reabrir, filtro por usuario y reintentos sin duplicados probados.
- [x] Logs sin contraseñas ni tokens; prueba de Crashlytics solo en debug; permiso `INTERNET` declarado.
- [x] Versión `1.0.0+1` definida en `pubspec.yaml`.
- [ ] Inicio con correo/contraseña habilitado en Firebase Console (Authentication → Sign-in method).
- [ ] Cuentas de prueba por rol creadas y roles asignados (ver `DATOS_PRUEBA.md`).
- [ ] Evento de Crashlytics verificado en la consola (QA-15).
- [x] APK release generado (`flutter build apk --release`, 59.7 MB), instalado en emulador Android 16 (API 36, x86_64) y abre en la pantalla de inicio de sesión con Firebase inicializado.
- [ ] Recorrido del APK con los tres roles (QA-16).
