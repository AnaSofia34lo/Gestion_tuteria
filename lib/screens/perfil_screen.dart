import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/core/diagnostico.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/widgets/mensajes.dart';

class PerfilScreen extends StatefulWidget {
  final Perfil perfil;
  const PerfilScreen({super.key, required this.perfil});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _saliendo = false;

  Future<void> _cerrarSesion() async {
    final ok = await confirmar(
      context,
      titulo: 'Cerrar sesión',
      mensaje:
          'Tus solicitudes pendientes quedan guardadas en este dispositivo y '
          'solo se enviarán cuando vuelvas a entrar con esta cuenta.',
      accion: 'Salir',
    );
    if (!ok || !mounted) return;
    setState(() => _saliendo = true);
    await AppScope.of(context).auth.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.perfil;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(p.nombre),
            subtitle: Text(p.email),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Rol'),
            subtitle: Text(p.rol.etiqueta),
          ),
          const Divider(),
          FilledButton.tonalIcon(
            onPressed: _saliendo ? null : _cerrarSesion,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
          // Mecanismo de prueba restringido a desarrollo: en el APK release
          // `kDebugMode` es false y el botón no existe.
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => ejecutarAccion(
                context,
                Diagnostico.enviarEventoDePrueba,
                exito: 'Evento de prueba enviado a Crashlytics',
              ),
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('Enviar evento de prueba a Crashlytics'),
            ),
          ],
        ],
      ),
    );
  }
}
