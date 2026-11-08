# Datos de prueba · G61-5

Todos los datos son ficticios. **Las contraseñas no se escriben en el
repositorio:** se comparten solo por el medio privado que indique el docente.

## Cuentas (una por rol, más un segundo estudiante para concurrencia)

| Cuenta | Rol | Cómo se obtiene |
|---|---|---|
| `edison.estudiante@gmial.com` | Estudiante | Registro desde la app |
| `edison.tutor@gmail.com` | Tutor | Registro desde la app y luego `rol = "tutor"` en Firestore Console |
| `edison.coordinador@gmail.com` | Coordinador | Registro desde la app y luego `rol = "coordinador"` en Firestore Console |

Para asignar el rol: Firebase Console → Firestore Database → `usuarios` →
documento con el uid de la cuenta → editar el campo `rol`.

## Recurso HTTP (9 registros)

`GET https://dummyjson.com/c/645c-94bf-42cf-a73a`, con el mismo contenido que
`docs/catalogo_asignaturas.json`: Cálculo diferencial, Álgebra lineal,
Estadística, Física mecánica, Química general, Programación orientada a
objetos, Estructuras de datos, Desarrollo móvil y Lectura crítica.

## Operaciones del negocio (6, distribuidas entre estados)

Se crean con la app en este orden. "Hoy +N" es la fecha relativa al día de la
prueba.

| # | Operación | Pasos | Estado final |
|---|---|---|---|
| 1 | Sesión propuesta | tutor1 propone **Estadística**, hoy +3, 10:00, capacidad 5 | `PROPUESTA` |
| 2 | Sesión rechazada | tutor1 propone **Química general**, hoy +3, 11:00. El coordinador la rechaza con motivo "Sin aula" | `RECHAZADA` |
| 3 | Escenario 1: último cupo | tutor1 propone **Desarrollo móvil**, hoy +2, 14:00, capacidad **1**. El coordinador la publica. estudiante1 y estudiante2 solicitan; el primero en sincronizar queda confirmado | Sesión `PUBLICADA`; una inscripción `CONFIRMADA` y otra `RECHAZADA` |
| 4 | Escenario 2: cancelación | tutor1 propone **Álgebra lineal**, hoy +2, 16:00, capacidad 3. Se publica. estudiante1 se inscribe y luego cancela | Inscripción `CANCELADA`, cupos 0/3 |
| 5 | Solicitud sin conexión | Con la operación 4 publicada, estudiante2 activa el modo avión y solicita cupo | Inscripción `SOLICITADA` + pendiente de envío (sincroniza al volver la red) |
| 6 | Escenario 3: cierre con asistencia | tutor1 propone **Cálculo diferencial** para la **próxima hora en punto**, capacidad 3. Se publica y estudiante1 y estudiante2 se inscriben. Al empezar la sesión, el tutor marca solo a estudiante1 como "Asistió". Al terminar, marca la sesión realizada. El coordinador intenta cerrar (bloqueado); luego el tutor marca a estudiante2 "No asistió" y el coordinador cierra | Inscripciones `ASISTIO` y `NO_ASISTIO`, sesión `CERRADA` |

La operación 6 depende de la hora real: las reglas de Firestore usan la hora
del servidor para permitir la asistencia (después del inicio) y para marcar la
sesión realizada (después del fin).
