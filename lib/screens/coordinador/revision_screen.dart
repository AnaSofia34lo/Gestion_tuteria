import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/screens/sesion_detalle_screen.dart';
import 'package:gestion_tutorias/widgets/error_view.dart';
import 'package:gestion_tutorias/widgets/loading_view.dart';
import 'package:gestion_tutorias/widgets/mensajes.dart';
import 'package:gestion_tutorias/widgets/sesion_card.dart';

/// Revisión de coordinación: propuestas por aprobar o rechazar y sesiones
/// realizadas por cerrar.
class RevisionScreen extends StatefulWidget {
  final Perfil perfil;
  const RevisionScreen({super.key, required this.perfil});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  Stream<List<Sesion>>? _sesiones;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sesiones ??= AppScope.of(context).sesiones.observarParaCoordinacion();
  }

  void _abrir(Sesion s) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SesionDetalleScreen(perfil: widget.perfil, sesion: s),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión de coordinación'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Sesion>>(
        stream: _sesiones,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              title: 'No pudimos cargar las sesiones',
              message: mensajeDeError(snapshot.error!),
              onRetry: () => setState(() {
                _sesiones = AppScope.of(
                  context,
                ).sesiones.observarParaCoordinacion();
              }),
            );
          }
          if (!snapshot.hasData) return const LoadingView();
          final propuestas = snapshot.data!
              .where((s) => s.estado == EstadoSesion.propuesta)
              .toList();
          final porCerrar = snapshot.data!
              .where((s) => s.estado == EstadoSesion.realizada)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _Seccion('Propuestas por revisar (${propuestas.length})'),
              if (propuestas.isEmpty)
                const _Vacio('No hay propuestas pendientes'),
              for (final s in propuestas)
                SesionCard(sesion: s, onTap: () => _abrir(s)),
              const SizedBox(height: 16),
              _Seccion('Realizadas por cerrar (${porCerrar.length})'),
              if (porCerrar.isEmpty) const _Vacio('No hay sesiones por cerrar'),
              for (final s in porCerrar)
                SesionCard(sesion: s, onTap: () => _abrir(s)),
            ],
          );
        },
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String texto;
  const _Seccion(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Vacio extends StatelessWidget {
  final String texto;
  const _Vacio(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(texto),
  );
}
