import 'package:flutter/material.dart';
import 'package:gestion_tutorias/catalogo_screen.dart';
import 'package:gestion_tutorias/core/api_config.dart';
import 'package:gestion_tutorias/repositories/asignatura_repository.dart';
import 'package:gestion_tutorias/services/asignatura_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final asignaturaRepository = AsignaturaRepository(
    AsignaturaService(ApiConfig.catalogoUrl),
  );
  runApp(TutoriasApp(asignaturaRepository: asignaturaRepository));
}

class TutoriasApp extends StatelessWidget {
  final AsignaturaRepository asignaturaRepository;

  const TutoriasApp({super.key, required this.asignaturaRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorías UdeM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5AA8)),
      ),
      home: CatalogoScreen(repository: asignaturaRepository),
    );
  }
}
