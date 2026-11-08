import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/repositories/auth_repository.dart';

void main() {
  group('Mensajes de autenticación', () {
    test('credenciales inválidas no revelan si el correo existe', () {
      expect(mensajeAuth('wrong-password'), 'Correo o contraseña incorrectos');
      expect(mensajeAuth('user-not-found'), 'Correo o contraseña incorrectos');
      expect(
        mensajeAuth('invalid-credential'),
        'Correo o contraseña incorrectos',
      );
    });

    test('correo inválido, contraseña débil, usuario existente y red', () {
      expect(mensajeAuth('invalid-email'), contains('formato válido'));
      expect(mensajeAuth('weak-password'), contains('débil'));
      expect(mensajeAuth('email-already-in-use'), contains('Ya existe'));
      expect(mensajeAuth('network-request-failed'), contains('Sin conexión'));
    });

    test(
      'un código desconocido da un mensaje genérico sin detalles técnicos',
      () {
        final m = mensajeAuth('internal-error-xyz');
        expect(m, isNot(contains('internal')));
      },
    );
  });

  group('Perfil y roles', () {
    test('un rol desconocido o ausente se trata como estudiante', () {
      expect(Rol.fromName(null), Rol.estudiante);
      expect(Rol.fromName('admin'), Rol.estudiante);
      expect(Rol.fromName('coordinador'), Rol.coordinador);
    });

    test('el perfil se enlaza al uid de Authentication', () {
      final p = Perfil.fromMap('uid-1', {
        'nombre': ' Ana ',
        'email': 'ana@test.co',
        'rol': 'tutor',
      });
      expect(p.uid, 'uid-1');
      expect(p.nombre, 'Ana');
      expect(p.rol, Rol.tutor);
    });
  });
}
