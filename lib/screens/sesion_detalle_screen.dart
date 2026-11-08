import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/core/formato.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/widgets/estado_chip.dart';
import 'package:gestion_tutorias/widgets/mensajes.dart';

/// Detalle de una sesión con las acciones de cada rol:
/// - Estudiante: solicitar cupo (se guarda local y se confirma con conexión).
/// - Tutor dueño: ver inscritos, registrar asistencia, marcar realizada.
/// - Coordinación: publicar o rechazar propuestas y cerrar sesiones.
class SesionDetalleScreen extends StatefulWidget {
  final Perfil perfil;
  final Sesion sesion;

  const SesionDetalleScreen({
    super.key,
    required this.perfil,
    required this.sesion,
  });

  @override
  State<SesionDetalleScreen> createState() => _SesionDetalleScreenState();
}

class _SesionDetalleScreenState extends State<SesionDetalleScreen> {
  Stream<Sesion?>? _sesion;
  Stream<List<Inscripcion>>? _inscritos;
  Stream<List<Inscripcion>>? _mias;
  bool _ocupado = false;

  Perfil get _perfil => widget.perfil;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sesion != null) return;
    final scope = AppScope.of(context);
    _sesion = scope.sesiones.observar(widget.sesion.id);
    final esTutorDueno =
        _perfil.rol == Rol.tutor && widget.sesion.tutorUid == _perfil.uid;
    if (esTutorDueno || _perfil.rol == Rol.coordinador) {
      _inscritos = scope.inscripciones.observarInscritos(widget.sesion);
    }
    if (_perfil.rol == Rol.estudiante) {
      _mias = scope.inscripciones.observarMisInscripciones(_perfil.uid);
    }
  }

  Future<void> _accion(Future<void> Function() accion, String exito) async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    await ejecutarAccion(context, accion, exito: exito);
    if (mounted) setState(() => _ocupado = false);
  }

  // ----- Estudiante -----

  Future<void> _solicitar(Sesion sesion) async {
    final repo = AppScope.of(context).inscripciones;
    final ok = await ejecutarAccion(
      context,
      () => repo.solicitar(sesion: sesion, estudiante: _perfil),
      exito:
          'Solicitud guardada. Queda pendiente hasta que el servidor la confirme.',
    );
    if (!ok) return;
    // Se intenta confirmar ya; sin conexión queda pendiente en Drift.
    unawaited(
      repo.sincronizarPendientes(_perfil.uid).then((r) {
        if (mounted && r.confirmadas + r.rechazadas > 0) {
          mostrarMensaje(context, r.resumen);
        }
      }),
    );
  }

  // ----- Coordinación -----

  Future<void> _rechazar(Sesion sesion) async {
    final motivo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar propuesta'),
        content: TextField(
          controller: motivo,
          decoration: const InputDecoration(labelText: 'Motivo'),
          maxLength: 120,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    final texto = motivo.text;
    motivo.dispose();
    if (ok != true || !mounted) return;
    await _accion(
      () => AppScope.of(context).sesiones.rechazar(sesion, _perfil, texto),
      'Propuesta rechazada',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la sesión')),
      body: StreamBuilder<Sesion?>(
        stream: _sesion,
        initialData: widget.sesion,
        builder: (context, snapshot) {
          final sesion = snapshot.data;
          if (sesion == null) {
            return const Center(child: Text('La sesión ya no existe'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Encabezado(sesion: sesion),
              const SizedBox(height: 16),
              ..._acciones(sesion),
              if (_inscritos != null) ...[
                const SizedBox(height: 16),
                _ListaInscritos(
                  stream: _inscritos!,
                  sesion: sesion,
                  perfil: _perfil,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _acciones(Sesion sesion) {
    final ahora = DateTime.now();
    final sesiones = AppScope.of(context).sesiones;
    switch (_perfil.rol) {
      case Rol.estudiante:
        return [
          StreamBuilder<List<Inscripcion>>(
            stream: _mias,
            builder: (context, snap) {
              final mia = (snap.data ?? const <Inscripcion>[])
                  .where((i) => i.sesionId == sesion.id)
                  .firstOrNull;
              if (mia != null && mia.estado.esActiva) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('Tu inscripción'),
                    subtitle: Wrap(
                      spacing: 6,
                      children: [
                        EstadoChip.inscripcion(mia.estado),
                        EstadoChip.sincronizacion(pendiente: mia.pendingSync),
                      ],
                    ),
                  ),
                );
              }
              final puede =
                  sesion.estado == EstadoSesion.publicada &&
                  !sesion.haIniciado(ahora);
              return FilledButton.icon(
                onPressed: puede && !_ocupado ? () => _solicitar(sesion) : null,
                icon: const Icon(Icons.how_to_reg),
                label: Text(
                  sesion.cuposDisponibles > 0
                      ? 'Solicitar cupo'
                      : 'Solicitar cupo (sin cupos ahora)',
                ),
              );
            },
          ),
        ];
      case Rol.tutor:
        if (sesion.tutorUid != _perfil.uid) return const [];
        return [
          if (sesion.estado == EstadoSesion.propuesta)
            const Text('Esperando aprobación de la coordinación.'),
          if (sesion.estado == EstadoSesion.rechazada)
            Text('Rechazada: ${sesion.motivoRechazo ?? 'sin motivo'}'),
          if (sesion.estado == EstadoSesion.publicada)
            FilledButton.icon(
              onPressed: !_ocupado && sesion.haTerminado(ahora)
                  ? () => _accion(
                      () => sesiones.marcarRealizada(sesion, _perfil),
                      'Sesión marcada como realizada',
                    )
                  : null,
              icon: const Icon(Icons.task_alt),
              label: Text(
                sesion.haTerminado(ahora)
                    ? 'Marcar como realizada'
                    : 'Podrás marcarla realizada al terminar',
              ),
            ),
        ];
      case Rol.coordinador:
        return [
          if (sesion.estado == EstadoSesion.propuesta)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _ocupado ? null : () => _rechazar(sesion),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _ocupado
                        ? null
                        : () => _accion(
                            () => sesiones.publicar(sesion, _perfil),
                            'Sesión publicada',
                          ),
                    child: const Text('Publicar'),
                  ),
                ),
              ],
            ),
          if (sesion.estado == EstadoSesion.realizada)
            FilledButton.icon(
              onPressed: _ocupado
                  ? null
                  : () async {
                      final ok = await confirmar(
                        context,
                        titulo: 'Cerrar sesión',
                        mensaje:
                            'Se verificará que todos los inscritos confirmados '
                            'tengan asistencia registrada.',
                        accion: 'Cerrar',
                      );
                      if (ok && mounted) {
                        await _accion(
                          () => sesiones.cerrar(sesion, _perfil),
                          'Sesión cerrada',
                        );
                      }
                    },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Cerrar sesión'),
            ),
        ];
    }
  }
}

class _Encabezado extends StatelessWidget {
  final Sesion sesion;
  const _Encabezado({required this.sesion});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sesion.asignaturaNombre, style: t.headlineSmall),
        const SizedBox(height: 4),
        Text(Formato.franja(sesion.inicio), style: t.titleMedium),
        if (sesion.tutorNombre.isNotEmpty) Text('Tutor: ${sesion.tutorNombre}'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            EstadoChip.sesion(sesion.estado),
            EstadoChip(
              texto: '${sesion.cuposOcupados}/${sesion.capacidad} ocupados',
              color: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }
}

class _ListaInscritos extends StatelessWidget {
  final Stream<List<Inscripcion>> stream;
  final Sesion sesion;
  final Perfil perfil;

  const _ListaInscritos({
    required this.stream,
    required this.sesion,
    required this.perfil,
  });

  @override
  Widget build(BuildContext context) {
    final puedeRegistrar =
        perfil.rol == Rol.tutor &&
        sesion.tutorUid == perfil.uid &&
        sesion.haIniciado(DateTime.now()) &&
        (sesion.estado == EstadoSesion.publicada ||
            sesion.estado == EstadoSesion.realizada);
    return StreamBuilder<List<Inscripcion>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text(
            'No se pudieron cargar los inscritos: ${mensajeDeError(snap.error!)}',
          );
        }
        if (!snap.hasData) return const LinearProgressIndicator();
        final inscritos = snap.data!
            .where((i) => i.estado != EstadoInscripcion.cancelada)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inscritos (${inscritos.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (inscritos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nadie se ha inscrito todavía.'),
              ),
            if (perfil.rol == Rol.tutor && !sesion.haIniciado(DateTime.now()))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('La asistencia se registra después del inicio.'),
              ),
            for (final i in inscritos)
              Card(
                child: ListTile(
                  title: Text(
                    i.estudianteNombre.isEmpty
                        ? i.estudianteUid
                        : i.estudianteNombre,
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: EstadoChip.inscripcion(i.estado),
                  ),
                  trailing: puedeRegistrar
                      ? _BotonesAsistencia(
                          inscripcion: i,
                          sesion: sesion,
                          tutor: perfil,
                        )
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BotonesAsistencia extends StatelessWidget {
  final Inscripcion inscripcion;
  final Sesion sesion;
  final Perfil tutor;

  const _BotonesAsistencia({
    required this.inscripcion,
    required this.sesion,
    required this.tutor,
  });

  Future<void> _registrar(BuildContext context, bool asistio) => ejecutarAccion(
    context,
    () => AppScope.of(context).inscripciones.registrarAsistencia(
      inscripcion: inscripcion,
      sesion: sesion,
      tutor: tutor,
      asistio: asistio,
    ),
    exito: asistio ? 'Asistencia registrada' : 'Inasistencia registrada',
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Asistió',
          color: Colors.green,
          isSelected: inscripcion.estado == EstadoInscripcion.asistio,
          icon: const Icon(Icons.check_circle_outline),
          selectedIcon: const Icon(Icons.check_circle),
          onPressed: () => _registrar(context, true),
        ),
        IconButton(
          tooltip: 'No asistió',
          color: Colors.red,
          isSelected: inscripcion.estado == EstadoInscripcion.noAsistio,
          icon: const Icon(Icons.cancel_outlined),
          selectedIcon: const Icon(Icons.cancel),
          onPressed: () => _registrar(context, false),
        ),
      ],
    );
  }
}
