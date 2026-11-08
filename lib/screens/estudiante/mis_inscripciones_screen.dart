import 'package:flutter/material.dart';
import 'package:gestion_tutorias/app_scope.dart';
import 'package:gestion_tutorias/core/formato.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/perfil.dart';
import 'package:gestion_tutorias/widgets/empty_view.dart';
import 'package:gestion_tutorias/widgets/estado_chip.dart';
import 'package:gestion_tutorias/widgets/loading_view.dart';
import 'package:gestion_tutorias/widgets/mensajes.dart';

/// Lee de Drift: funciona sin conexión y distingue el estado del negocio
/// (solicitada, confirmada...) del estado de sincronización.
class MisInscripcionesScreen extends StatefulWidget {
  final Perfil perfil;
  const MisInscripcionesScreen({super.key, required this.perfil});

  @override
  State<MisInscripcionesScreen> createState() => _MisInscripcionesScreenState();
}

class _MisInscripcionesScreenState extends State<MisInscripcionesScreen> {
  Stream<List<Inscripcion>>? _inscripciones;
  bool _sincronizando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inscripciones == null) {
      final repo = AppScope.of(context).inscripciones;
      _inscripciones = repo.observarMisInscripciones(widget.perfil.uid);
      // Al abrir: envía pendientes y trae la asistencia registrada por
      // tutores. Se agenda después del primer frame (usa setState).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sincronizar(silencioso: true);
      });
    }
  }

  Future<void> _sincronizar({bool silencioso = false}) async {
    if (_sincronizando) return;
    setState(() => _sincronizando = true);
    final repo = AppScope.of(context).inscripciones;
    try {
      final r = await repo.sincronizarPendientes(widget.perfil.uid);
      await repo.refrescarDesdeServidor(widget.perfil.uid);
      if (mounted && (!silencioso || r.confirmadas + r.rechazadas > 0)) {
        mostrarMensaje(context, r.resumen);
      }
    } catch (e) {
      if (mounted) mostrarMensaje(context, mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _cancelar(Inscripcion i) async {
    final ok = await confirmar(
      context,
      titulo: 'Cancelar inscripción',
      mensaje: i.estado == EstadoInscripcion.confirmada
          ? 'Liberarás tu cupo en ${i.asignaturaNombre}. Necesitas conexión.'
          : 'Tu solicitud aún no se ha enviado; se cancelará en este dispositivo.',
      accion: 'Cancelar inscripción',
    );
    if (!ok || !mounted) return;
    await ejecutarAccion(
      context,
      () => AppScope.of(context).inscripciones.cancelar(i),
      exito: 'Inscripción cancelada',
    );
  }

  Future<void> _descartar(Inscripcion i) => ejecutarAccion(
    context,
    () => AppScope.of(context).inscripciones.descartar(i),
    exito: 'Registro descartado',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis inscripciones'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            onPressed: _sincronizando ? null : _sincronizar,
            icon: _sincronizando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: StreamBuilder<List<Inscripcion>>(
        stream: _inscripciones,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingView();
          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const EmptyView(
              message:
                  'Aún no tienes inscripciones.\nBusca una sesión en "Sesiones".',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, index) => _InscripcionTile(
              inscripcion: lista[index],
              onCancelar: _cancelar,
              onDescartar: _descartar,
            ),
          );
        },
      ),
    );
  }
}

class _InscripcionTile extends StatelessWidget {
  final Inscripcion inscripcion;
  final ValueChanged<Inscripcion> onCancelar;
  final ValueChanged<Inscripcion> onDescartar;

  const _InscripcionTile({
    required this.inscripcion,
    required this.onCancelar,
    required this.onDescartar,
  });

  @override
  Widget build(BuildContext context) {
    final i = inscripcion;
    final inicio = i.inicioSesion;
    final antesDelInicio = inicio == null || DateTime.now().isBefore(inicio);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i.asignaturaNombre.isEmpty
                  ? 'Sesión ${i.sesionId}'
                  : i.asignaturaNombre,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (inicio != null) Text(Formato.franja(inicio)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                EstadoChip.inscripcion(i.estado),
                EstadoChip.sincronizacion(pendiente: i.pendingSync),
              ],
            ),
            if (i.estado == EstadoInscripcion.solicitada)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Pendiente: todavía no es una plaza garantizada.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            if (i.ultimoError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  i.ultimoError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  if (i.estado.esActiva && antesDelInicio)
                    TextButton(
                      onPressed: () => onCancelar(i),
                      child: const Text('Cancelar'),
                    ),
                  if (i.estado == EstadoInscripcion.rechazada ||
                      i.estado == EstadoInscripcion.cancelada)
                    TextButton(
                      onPressed: () => onDescartar(i),
                      child: const Text('Descartar'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
