import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/screens/sesion_detalle_screen.dart';
import 'package:gestion_tutorias/widgets/empty_view.dart';
import 'package:gestion_tutorias/widgets/error_view.dart';
import 'package:gestion_tutorias/widgets/loading_view.dart';
import 'package:gestion_tutorias/widgets/mensajes.dart';
import 'package:gestion_tutorias/widgets/sesion_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sesiones publicadas y futuras. El filtro "solo con cupos" se guarda en
/// SharedPreferences y se restaura al volver a la pantalla.
class SesionesDisponiblesScreen extends StatefulWidget {
  static const prefSoloConCupos = 'sesiones_solo_con_cupos';

  final Perfil perfil;
  const SesionesDisponiblesScreen({super.key, required this.perfil});

  @override
  State<SesionesDisponiblesScreen> createState() =>
      _SesionesDisponiblesScreenState();
}

class _SesionesDisponiblesScreenState extends State<SesionesDisponiblesScreen> {
  Stream<List<Sesion>>? _sesiones;
  bool _soloConCupos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se crea una sola vez: reconstruir no duplica la escucha.
    _sesiones ??= AppScope.of(context).sesiones.observarDisponibles();
  }

  @override
  void initState() {
    super.initState();
    _cargarFiltro();
  }

  Future<void> _cargarFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _soloConCupos =
          prefs.getBool(SesionesDisponiblesScreen.prefSoloConCupos) ?? false;
    });
  }

  Future<void> _cambiarFiltro(bool valor) async {
    setState(() => _soloConCupos = valor);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SesionesDisponiblesScreen.prefSoloConCupos, valor);
  }

  void _reintentar() {
    setState(() {
      _sesiones = AppScope.of(context).sesiones.observarDisponibles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones disponibles'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Sesion>>(
        stream: _sesiones,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              title: 'No pudimos cargar las sesiones',
              message: mensajeDeError(snapshot.error!),
              onRetry: _reintentar,
            );
          }
          if (!snapshot.hasData) return const LoadingView();

          final todas = snapshot.data!;
          final visibles = _soloConCupos
              ? todas.where((s) => s.cuposDisponibles > 0).toList()
              : todas;
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Solo sesiones con cupos'),
                value: _soloConCupos,
                onChanged: _cambiarFiltro,
              ),
              Expanded(
                child: visibles.isEmpty
                    ? const EmptyView(
                        message: 'No hay sesiones publicadas por ahora',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: visibles.length,
                        itemBuilder: (context, i) => SesionCard(
                          sesion: visibles[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SesionDetalleScreen(
                                perfil: widget.perfil,
                                sesion: visibles[i],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
