import 'package:flutter/material.dart';
import 'package:gestion_tutorias/models/inscripcion.dart';
import 'package:gestion_tutorias/models/sesion.dart';

class EstadoChip extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData? icono;

  const EstadoChip({
    super.key,
    required this.texto,
    required this.color,
    this.icono,
  });

  factory EstadoChip.sesion(EstadoSesion estado) => EstadoChip(
    texto: estado.etiqueta,
    color: switch (estado) {
      EstadoSesion.propuesta => Colors.orange,
      EstadoSesion.publicada => Colors.green,
      EstadoSesion.rechazada => Colors.red,
      EstadoSesion.realizada => Colors.blue,
      EstadoSesion.cerrada => Colors.blueGrey,
    },
  );

  /// Estado del negocio. El de sincronización se muestra aparte con
  /// [EstadoChip.sincronizacion] para no confundir pendiente con confirmado.
  factory EstadoChip.inscripcion(EstadoInscripcion estado) => EstadoChip(
    texto: estado.etiqueta,
    color: switch (estado) {
      EstadoInscripcion.solicitada => Colors.orange,
      EstadoInscripcion.confirmada => Colors.green,
      EstadoInscripcion.cancelada => Colors.blueGrey,
      EstadoInscripcion.rechazada => Colors.red,
      EstadoInscripcion.asistio => Colors.blue,
      EstadoInscripcion.noAsistio => Colors.deepOrange,
    },
  );

  factory EstadoChip.sincronizacion({required bool pendiente}) => EstadoChip(
    texto: pendiente ? 'Pendiente de envío' : 'Sincronizada',
    color: pendiente ? Colors.amber.shade800 : Colors.teal,
    icono: pendiente ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
