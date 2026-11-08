import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/screens/sesion_detalle_screen.dart';
import 'package:gestion_tutorias/screens/tutor/nueva_sesion_screen.dart';
import 'package:gestion_tutorias/widgets/empty_view.dart';
import 'package:gestion_tutorias/widgets/error_view.dart';
import 'package:gestion_tutorias/widgets/loading_view.dart';
import 'package:gestion_tutorias/widgets/mensajes.dart';
import 'package:gestion_tutorias/widgets/sesion_card.dart';

class MisSesionesTutorScreen extends StatefulWidget {
  final Perfil perfil;
  const MisSesionesTutorScreen({super.key, required this.perfil});

  @override
  State<MisSesionesTutorScreen> createState() => _MisSesionesTutorScreenState();
}

class _MisSesionesTutorScreenState extends State<MisSesionesTutorScreen> {
  Stream<List<Sesion>>? _sesiones;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sesiones ??= AppScope.of(
      context,
    ).sesiones.observarDelTutor(widget.perfil.uid);
  }

  void _reintentar() => setState(() {
    _sesiones = AppScope.of(
      context,
    ).sesiones.observarDelTutor(widget.perfil.uid);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis sesiones'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NuevaSesionScreen(tutor: widget.perfil),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Proponer sesión'),
      ),
      body: StreamBuilder<List<Sesion>>(
        stream: _sesiones,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              title: 'No pudimos cargar tus sesiones',
              message: mensajeDeError(snapshot.error!),
              onRetry: _reintentar,
            );
          }
          if (!snapshot.hasData) return const LoadingView();
          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const EmptyView(
              message: 'Aún no has propuesto sesiones.\nUsa "Proponer sesión".',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            itemCount: lista.length,
            itemBuilder: (context, i) => SesionCard(
              sesion: lista[i],
              mostrarTutor: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SesionDetalleScreen(
                    perfil: widget.perfil,
                    sesion: lista[i],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
