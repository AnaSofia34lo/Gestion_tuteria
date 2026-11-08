import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/core/formato.dart';
import 'package:gestion_tutorias/models/asignatura.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/widgets/error_view.dart';
import 'package:gestion_tutorias/widgets/loading_view.dart';
import 'package:gestion_tutorias/widgets/mensajes.dart';

/// Formulario del tutor. La sesión nace PROPUESTA; la coordinación la
/// publica. Las franjas son fijas de una hora (hora en punto).
class NuevaSesionScreen extends StatefulWidget {
  final Perfil tutor;
  const NuevaSesionScreen({super.key, required this.tutor});

  @override
  State<NuevaSesionScreen> createState() => _NuevaSesionScreenState();
}

class _NuevaSesionScreenState extends State<NuevaSesionScreen> {
  late Future<List<Asignatura>> _catalogo;
  Asignatura? _asignatura;
  DateTime _dia = DateTime.now().add(const Duration(days: 1));
  int _hora = 10;
  int _capacidad = 5;
  bool _guardando = false;

  static const _horas = [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catalogo = AppScope.of(context).asignaturas.getAsignaturas();
  }

  DateTime get _inicio => DateTime(_dia.year, _dia.month, _dia.day, _hora);

  Future<void> _elegirDia() async {
    final hoy = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: hoy.add(const Duration(days: 120)),
    );
    if (dia != null) setState(() => _dia = dia);
  }

  Future<void> _guardar() async {
    final asignatura = _asignatura;
    if (asignatura == null) {
      mostrarMensaje(context, 'Elige una asignatura del catálogo');
      return;
    }
    if (_guardando) return;
    setState(() => _guardando = true);
    final ok = await ejecutarAccion(
      context,
      () => AppScope.of(context).sesiones.proponer(
        tutor: widget.tutor,
        asignatura: asignatura,
        inicio: _inicio,
        capacidad: _capacidad,
      ),
      exito: 'Sesión propuesta. La coordinación debe aprobarla.',
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proponer sesión')),
      body: FutureBuilder<List<Asignatura>>(
        future: _catalogo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              title: 'Se necesita el catálogo de asignaturas',
              message: mensajeDeError(snapshot.error!),
              onRetry: () => setState(() {
                _catalogo = AppScope.of(context).asignaturas.refrescar();
              }),
            );
          }
          final asignaturas = snapshot.data ?? const <Asignatura>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<Asignatura>(
                initialValue: _asignatura,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Asignatura'),
                items: [
                  for (final a in asignaturas)
                    DropdownMenuItem(
                      value: a,
                      child: Text('${a.nombre} · ${a.area}'),
                    ),
                ],
                onChanged: (a) => setState(() => _asignatura = a),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Día'),
                subtitle: Text(Formato.fecha(_dia)),
                trailing: TextButton(
                  onPressed: _elegirDia,
                  child: const Text('Cambiar'),
                ),
              ),
              DropdownButtonFormField<int>(
                initialValue: _hora,
                decoration: const InputDecoration(labelText: 'Franja (1 hora)'),
                items: [
                  for (final h in _horas)
                    DropdownMenuItem(
                      value: h,
                      child: Text(
                        '${h.toString().padLeft(2, '0')}:00 – '
                        '${(h + 1).toString().padLeft(2, '0')}:00',
                      ),
                    ),
                ],
                onChanged: (h) => setState(() => _hora = h ?? _hora),
              ),
              const SizedBox(height: 16),
              Text('Capacidad: $_capacidad estudiante(s)'),
              Slider(
                value: _capacidad.toDouble(),
                min: Sesion.capacidadMinima.toDouble(),
                max: Sesion.capacidadMaxima.toDouble(),
                divisions: Sesion.capacidadMaxima - Sesion.capacidadMinima,
                label: '$_capacidad',
                onChanged: (v) => setState(() => _capacidad = v.round()),
              ),
              const SizedBox(height: 8),
              Text('Inicio: ${Formato.franja(_inicio)}'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Enviar propuesta'),
              ),
            ],
          );
        },
      ),
    );
  }
}
