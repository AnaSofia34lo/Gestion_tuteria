import 'package:flutter/material.dart';
import 'package:gestion_tutorias/catalogo_screen.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/screens/coordinador/revision_screen.dart';
import 'package:gestion_tutorias/screens/estudiante/mis_inscripciones_screen.dart';
import 'package:gestion_tutorias/screens/estudiante/sesiones_disponibles_screen.dart';
import 'package:gestion_tutorias/screens/perfil_screen.dart';
import 'package:gestion_tutorias/screens/tutor/mis_sesiones_tutor_screen.dart';

class _Pestana {
  final String titulo;
  final IconData icono;
  final Widget Function() pantalla;
  const _Pestana(this.titulo, this.icono, this.pantalla);
}

/// Cada rol ve solo sus pestañas: no existe navegación hacia pantallas de
/// otro rol. Firestore valida además cada operación con sus reglas.
class HomeScreen extends StatefulWidget {
  final Perfil perfil;
  const HomeScreen({super.key, required this.perfil});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  List<_Pestana> _pestanas(Perfil perfil) {
    final catalogo = _Pestana(
      'Catálogo',
      Icons.menu_book_outlined,
      () => CatalogoScreen(repository: AppScope.of(context).asignaturas),
    );
    final cuenta = _Pestana(
      'Perfil',
      Icons.person_outline,
      () => PerfilScreen(perfil: perfil),
    );
    return switch (perfil.rol) {
      Rol.estudiante => [
        _Pestana(
          'Sesiones',
          Icons.event_available_outlined,
          () => SesionesDisponiblesScreen(perfil: perfil),
        ),
        _Pestana(
          'Mis inscripciones',
          Icons.bookmark_border,
          () => MisInscripcionesScreen(perfil: perfil),
        ),
        catalogo,
        cuenta,
      ],
      Rol.tutor => [
        _Pestana(
          'Mis sesiones',
          Icons.co_present_outlined,
          () => MisSesionesTutorScreen(perfil: perfil),
        ),
        catalogo,
        cuenta,
      ],
      Rol.coordinador => [
        _Pestana(
          'Revisión',
          Icons.fact_check_outlined,
          () => RevisionScreen(perfil: perfil),
        ),
        catalogo,
        cuenta,
      ],
    };
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió el rol (asignado en consola), se vuelve a la primera pestaña.
    if (oldWidget.perfil.rol != widget.perfil.rol) _indice = 0;
  }

  @override
  Widget build(BuildContext context) {
    final pestanas = _pestanas(widget.perfil);
    final indice = _indice.clamp(0, pestanas.length - 1);
    return Scaffold(
      body: pestanas[indice].pantalla(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: [
          for (final p in pestanas)
            NavigationDestination(icon: Icon(p.icono), label: p.titulo),
        ],
      ),
    );
  }
}
