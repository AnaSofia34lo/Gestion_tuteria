// Pruebas de firestore.rules contra el emulador de Firestore.
// Ejecutar: npm install && npm test   (requiere Firebase CLI y Java 11+)
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  runTransaction,
  setDoc,
  Timestamp,
  updateDoc,
  increment,
} from 'firebase/firestore';

const HORA = 60 * 60 * 1000;
let env;

const usuarios = {
  est1: { nombre: 'Ana', email: 'est1@test.co', rol: 'estudiante' },
  est2: { nombre: 'Luis', email: 'est2@test.co', rol: 'estudiante' },
  tutor1: { nombre: 'Tutor Uno', email: 'tutor1@test.co', rol: 'tutor' },
  tutor2: { nombre: 'Tutor Dos', email: 'tutor2@test.co', rol: 'tutor' },
  coord: { nombre: 'Coordinación', email: 'coord@test.co', rol: 'coordinador' },
};

const db = (uid) =>
  env.authenticatedContext(uid, { email: usuarios[uid]?.email ?? `${uid}@test.co` }).firestore();

/** Franja fija futura (hora en punto). */
function franja(horasDesdeAhora) {
  const d = new Date(Date.now() + horasDesdeAhora * HORA);
  d.setMinutes(0, 0, 0);
  return d;
}

function sesion(datos = {}) {
  return {
    asignaturaId: '8',
    asignaturaNombre: 'Desarrollo móvil',
    tutorUid: 'tutor1',
    tutorNombre: 'Tutor Uno',
    inicio: Timestamp.fromDate(franja(48)),
    capacidad: 2,
    cuposOcupados: 0,
    estado: 'publicada',
    ...datos,
  };
}

async function sembrar(fn) {
  await env.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));
}

/** Misma transacción que FirestoreInscripcionRemoteDataSource.confirmar. */
function confirmar(firestore, sesionId, uid) {
  return runTransaction(firestore, async (tx) => {
    const sesionRef = doc(firestore, 'sesiones', sesionId);
    const insRef = doc(firestore, 'inscripciones', `${sesionId}_${uid}`);
    const s = (await tx.get(sesionRef)).data();
    await tx.get(insRef);
    if (s.cuposOcupados >= s.capacidad) throw new Error('Sin cupos');
    tx.set(insRef, {
      sesionId,
      estudianteUid: uid,
      estudianteNombre: usuarios[uid].nombre,
      tutorUid: s.tutorUid,
      asignaturaNombre: s.asignaturaNombre,
      inicioSesion: s.inicio,
      estado: 'confirmada',
      actualizadoEn: Timestamp.now(),
    });
    tx.update(sesionRef, { cuposOcupados: s.cuposOcupados + 1 });
  });
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-tutorias',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(async () => env?.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await sembrar(async (f) => {
    for (const [uid, datos] of Object.entries(usuarios)) {
      await setDoc(doc(f, 'usuarios', uid), datos);
    }
  });
});

describe('Autenticación y roles', () => {
  test('un usuario nuevo solo puede crearse como estudiante', async () => {
    const nuevo = env.authenticatedContext('nuevo', { email: 'nuevo@test.co' }).firestore();
    await assertFails(
      setDoc(doc(nuevo, 'usuarios', 'nuevo'), { nombre: 'X', email: 'nuevo@test.co', rol: 'coordinador' }),
    );
    await assertSucceeds(
      setDoc(doc(nuevo, 'usuarios', 'nuevo'), { nombre: 'X', email: 'nuevo@test.co', rol: 'estudiante' }),
    );
  });

  test('nadie puede cambiar su propio rol ni crear el perfil de otro', async () => {
    await assertFails(updateDoc(doc(db('est1'), 'usuarios', 'est1'), { rol: 'tutor' }));
    await assertSucceeds(updateDoc(doc(db('est1'), 'usuarios', 'est1'), { nombre: 'Ana María' }));
    const nuevo = env.authenticatedContext('nuevo', { email: 'nuevo@test.co' }).firestore();
    await assertFails(
      setDoc(doc(nuevo, 'usuarios', 'otro'), { nombre: 'X', email: 'nuevo@test.co', rol: 'estudiante' }),
    );
  });

  test('sin sesión no se lee nada', async () => {
    await sembrar((f) => setDoc(doc(f, 'sesiones', 's1'), sesion()));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'sesiones', 's1')));
  });
});

describe('Sesiones', () => {
  test('solo un tutor propone, a su nombre y con capacidad 1-10', async () => {
    const propuesta = sesion({ estado: 'propuesta' });
    await assertFails(setDoc(doc(db('est1'), 'sesiones', 'a'), propuesta));
    await assertFails(setDoc(doc(db('tutor2'), 'sesiones', 'a'), propuesta)); // suplanta tutor1
    await assertFails(setDoc(doc(db('tutor1'), 'sesiones', 'a'), { ...propuesta, capacidad: 11 }));
    await assertFails(
      setDoc(doc(db('tutor1'), 'sesiones', 'a'), { ...propuesta, inicio: Timestamp.fromDate(franja(-2)) }),
    );
    await assertSucceeds(setDoc(doc(db('tutor1'), 'sesiones', 'a'), propuesta));
  });

  test('coordinación publica reservando la franja; la misma franja no se repite', async () => {
    const inicio = Timestamp.fromDate(franja(72));
    await sembrar(async (f) => {
      await setDoc(doc(f, 'sesiones', 'p1'), sesion({ estado: 'propuesta', inicio }));
      await setDoc(doc(f, 'sesiones', 'p2'), sesion({ estado: 'propuesta', inicio }));
    });
    const publicar = (f, id) =>
      runTransaction(f, async (tx) => {
        const franjaRef = doc(f, 'franjas', `tutor1_${inicio.toMillis()}`);
        tx.set(franjaRef, { tutorUid: 'tutor1', sesionId: id });
        tx.update(doc(f, 'sesiones', id), { estado: 'publicada' });
      });
    await assertFails(publicar(db('tutor1'), 'p1'));
    await assertSucceeds(publicar(db('coord'), 'p1'));
    await assertFails(publicar(db('coord'), 'p2'));
    // Sin reservar la franja tampoco se publica.
    await assertFails(updateDoc(doc(db('coord'), 'sesiones', 'p2'), { estado: 'publicada' }));
  });

  test('coordinación rechaza propuestas; el tutor no puede publicarse a sí mismo', async () => {
    await sembrar((f) => setDoc(doc(f, 'sesiones', 'p1'), sesion({ estado: 'propuesta' })));
    await assertFails(updateDoc(doc(db('tutor1'), 'sesiones', 'p1'), { estado: 'rechazada' }));
    await assertSucceeds(
      updateDoc(doc(db('coord'), 'sesiones', 'p1'), { estado: 'rechazada', motivoRechazo: 'Sin aula' }),
    );
  });

  test('el tutor marca realizada solo cuando terminó; coordinación cierra', async () => {
    await sembrar(async (f) => {
      await setDoc(doc(f, 'sesiones', 'fut'), sesion());
      await setDoc(doc(f, 'sesiones', 'pas'), sesion({ inicio: Timestamp.fromDate(franja(-3)) }));
    });
    await assertFails(updateDoc(doc(db('tutor1'), 'sesiones', 'fut'), { estado: 'realizada' }));
    await assertFails(updateDoc(doc(db('tutor2'), 'sesiones', 'pas'), { estado: 'realizada' }));
    await assertSucceeds(updateDoc(doc(db('tutor1'), 'sesiones', 'pas'), { estado: 'realizada' }));
    await assertFails(updateDoc(doc(db('tutor1'), 'sesiones', 'pas'), { estado: 'cerrada' }));
    await assertSucceeds(updateDoc(doc(db('coord'), 'sesiones', 'pas'), { estado: 'cerrada' }));
  });
});

describe('Inscripciones y cupos', () => {
  beforeEach(() => sembrar((f) => setDoc(doc(f, 'sesiones', 's1'), sesion({ capacidad: 2, cuposOcupados: 1 }))));

  test('confirmar inscripción y cupo en la misma transacción', async () => {
    await assertSucceeds(confirmar(db('est1'), 's1', 'est1'));
    const s = await getDoc(doc(db('est1'), 'sesiones', 's1'));
    assert.equal(s.data().cuposOcupados, 2);
  });

  test('no se puede subir el contador sin inscripción ni inscribirse sin contador', async () => {
    await assertFails(updateDoc(doc(db('est1'), 'sesiones', 's1'), { cuposOcupados: increment(1) }));
    await assertFails(
      setDoc(doc(db('est1'), 'inscripciones', 's1_est1'), {
        sesionId: 's1', estudianteUid: 'est1', tutorUid: 'tutor1', estado: 'confirmada',
      }),
    );
  });

  test('un estudiante no puede inscribir a otro ni usar otro id', async () => {
    await assertFails(confirmar(db('est1'), 's1', 'est2'));
  });

  test('escenario 1: dos estudiantes por el último cupo, solo uno queda', async () => {
    const resultados = await Promise.allSettled([
      confirmar(db('est1'), 's1', 'est1'),
      confirmar(db('est2'), 's1', 'est2'),
    ]);
    const exitosos = resultados.filter((r) => r.status === 'fulfilled');
    assert.equal(exitosos.length, 1);
    const s = await getDoc(doc(db('coord'), 'sesiones', 's1'));
    assert.equal(s.data().cuposOcupados, 2);
  });

  test('escenario 2: cancelar libera el cupo en la misma transacción', async () => {
    await confirmar(db('est1'), 's1', 'est1');
    const f = db('est1');
    await assertFails(updateDoc(doc(f, 'inscripciones', 's1_est1'), { estado: 'cancelada' }));
    await assertSucceeds(
      runTransaction(f, async (tx) => {
        tx.update(doc(f, 'inscripciones', 's1_est1'), { estado: 'cancelada' });
        tx.update(doc(f, 'sesiones', 's1'), { cuposOcupados: 1 });
      }),
    );
    const s = await getDoc(doc(f, 'sesiones', 's1'));
    assert.equal(s.data().cuposOcupados, 1);
  });

  test('el estudiante solo lee sus inscripciones; tutor y coordinación las de su sesión', async () => {
    await confirmar(db('est1'), 's1', 'est1');
    await assertSucceeds(getDoc(doc(db('est1'), 'inscripciones', 's1_est1')));
    await assertFails(getDoc(doc(db('est2'), 'inscripciones', 's1_est1')));
    await assertSucceeds(getDoc(doc(db('tutor1'), 'inscripciones', 's1_est1')));
    await assertFails(getDoc(doc(db('tutor2'), 'inscripciones', 's1_est1')));
    await assertSucceeds(getDoc(doc(db('coord'), 'inscripciones', 's1_est1')));
  });
});

describe('Asistencia', () => {
  beforeEach(() =>
    sembrar(async (f) => {
      await setDoc(doc(f, 'sesiones', 'pas'), sesion({ inicio: Timestamp.fromDate(franja(-1)), cuposOcupados: 1 }));
      await setDoc(doc(f, 'inscripciones', 'pas_est1'), {
        sesionId: 'pas', estudianteUid: 'est1', tutorUid: 'tutor1', estado: 'confirmada',
      });
    }),
  );

  test('solo el tutor de la sesión registra asistencia', async () => {
    await assertFails(updateDoc(doc(db('tutor2'), 'inscripciones', 'pas_est1'), { estado: 'asistio' }));
    await assertFails(updateDoc(doc(db('est1'), 'inscripciones', 'pas_est1'), { estado: 'asistio' }));
    await assertFails(updateDoc(doc(db('coord'), 'inscripciones', 'pas_est1'), { estado: 'asistio' }));
    await assertSucceeds(updateDoc(doc(db('tutor1'), 'inscripciones', 'pas_est1'), { estado: 'asistio' }));
  });

  test('el estudiante ya no puede cancelar una sesión iniciada', async () => {
    const f = db('est1');
    await assertFails(
      runTransaction(f, async (tx) => {
        tx.update(doc(f, 'inscripciones', 'pas_est1'), { estado: 'cancelada' });
        tx.update(doc(f, 'sesiones', 'pas'), { cuposOcupados: 0 });
      }),
    );
  });
});
