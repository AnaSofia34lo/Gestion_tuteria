import 'package:flutter/material.dart';
import 'package:gestion_tutorias/core/formato.dart';
import 'package:gestion_tutorias/models/sesion.dart';
import 'package:gestion_tutorias/widgets/estado_chip.dart';

class SesionCard extends StatelessWidget {
  final Sesion sesion;
  final VoidCallback onTap;
  final bool mostrarTutor;

  const SesionCard({
    super.key,
    required this.sesion,
    required this.onTap,
    this.mostrarTutor = true,
  });

  @override
  Widget build(BuildContext context) {
    final sinCupo = sesion.cuposDisponibles <= 0;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.event_note_outlined),
        title: Text(
          sesion.asignaturaNombre.isEmpty
              ? 'Asignatura ${sesion.asignaturaId}'
              : sesion.asignaturaNombre,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formato.franja(sesion.inicio)),
            if (mostrarTutor && sesion.tutorNombre.isNotEmpty)
              Text('Tutor: ${sesion.tutorNombre}'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                EstadoChip.sesion(sesion.estado),
                EstadoChip(
                  texto: sinCupo
                      ? 'Sin cupos'
                      : '${sesion.cuposDisponibles} de ${sesion.capacidad} cupos',
                  color: sinCupo ? Colors.red : Colors.indigo,
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
