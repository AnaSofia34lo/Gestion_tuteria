import 'package:flutter/material.dart';
import 'package:gestion_tutorias/models/asignatura.dart';
import 'package:gestion_tutorias/repositories/asignatura_repository.dart';
import 'package:gestion_tutorias/widgets/empty_view.dart';
import 'package:gestion_tutorias/widgets/error_view.dart';
import 'package:gestion_tutorias/widgets/loading_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Catálogo de asignaturas y temas (HTTP) con filtro por área.
/// El área elegida se guarda en SharedPreferences y se restaura al abrir.
class CatalogoScreen extends StatefulWidget {
  static const prefAreaKey = 'catalogo_area_filtro';

  final AsignaturaRepository repository;

  const CatalogoScreen({super.key, required this.repository});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  // Se crea una sola vez: reconstruir el widget no repite la petición.
  late Future<List<Asignatura>> _futureAsignaturas;
  String? _areaSeleccionada;

  @override
  void initState() {
    super.initState();
    _futureAsignaturas = widget.repository.getAsignaturas();
    _cargarFiltro();
  }

  Future<void> _cargarFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _areaSeleccionada = prefs.getString(CatalogoScreen.prefAreaKey);
    });
  }

  Future<void> _guardarFiltro(String? area) async {
    setState(() => _areaSeleccionada = area);
    final prefs = await SharedPreferences.getInstance();
    if (area == null) {
      await prefs.remove(CatalogoScreen.prefAreaKey);
    } else {
      await prefs.setString(CatalogoScreen.prefAreaKey, area);
    }
  }

  void _reintentar() {
    setState(() {
      _futureAsignaturas = widget.repository.refrescar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignaturas y temas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Asignatura>>(
      future: _futureAsignaturas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(
            title: 'No pudimos cargar el catálogo',
            message: snapshot.error.toString(),
            onRetry: _reintentar,
          );
        }

        final todas = snapshot.data ?? [];
        if (todas.isEmpty) {
          return const EmptyView(
            message: 'Todavía no hay asignaturas en el catálogo',
          );
        }

        final areas = widget.repository.areas(todas);
        // Si el área guardada ya no existe en el catálogo, se ignora.
        final area = areas.contains(_areaSeleccionada)
            ? _areaSeleccionada
            : null;
        final visibles = widget.repository.filtrarPorArea(todas, area);

        return RefreshIndicator(
          onRefresh: () async => _reintentar(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FiltroAreas(
                areas: areas,
                seleccionada: area,
                onChanged: _guardarFiltro,
              ),
              const SizedBox(height: 12),
              Text(
                '${visibles.length} de ${todas.length} asignaturas',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final asignatura in visibles)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: Text(asignatura.nombre),
                    subtitle: Text(
                      asignatura.descripcion.isEmpty
                          ? asignatura.area
                          : '${asignatura.area} · ${asignatura.descripcion}',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FiltroAreas extends StatelessWidget {
  final List<String> areas;
  final String? seleccionada;
  final ValueChanged<String?> onChanged;

  const _FiltroAreas({
    required this.areas,
    required this.seleccionada,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Todas'),
          selected: seleccionada == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final area in areas)
          ChoiceChip(
            label: Text(area),
            selected: seleccionada == area,
            onSelected: (_) => onChanged(area),
          ),
      ],
    );
  }
}
