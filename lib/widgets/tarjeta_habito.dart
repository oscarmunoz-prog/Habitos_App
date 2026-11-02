import 'package:flutter/material.dart';

// Tarjeta que representa un hábito dentro de la lista.
// Solo muestra los datos que recibe y ejecuta los callbacks: no sabe nada
// de la base de datos. La pantalla decide qué hacer en cada acción.
class TarjetaHabito extends StatelessWidget {
  final String nombre;
  // Color identificativo del hábito.
  final Color color;
  // true si el hábito se ha completado hoy.
  final bool completado;
  // Icono opcional. Si no se indica, se usa Icons.task_alt.
  final IconData icono;
  final VoidCallback onCompletar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TarjetaHabito({
    super.key,
    required this.nombre,
    required this.color,
    required this.completado,
    this.icono = Icons.task_alt,
    required this.onCompletar,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Los completados se distinguen por el texto, el icono y el color.
    final colorEstado = completado ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icono, color: color, size: 36),
            const SizedBox(width: 12),
            // Expanded hace que los textos usen el espacio que queda.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        completado ? Icons.check_circle : Icons.schedule,
                        color: colorEstado,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        completado ? 'Completado hoy' : 'Pendiente',
                        style: TextStyle(color: colorEstado),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: completado ? 'Desmarcar' : 'Completar',
              onPressed: onCompletar,
              icon: Icon(
                completado ? Icons.check_box : Icons.check_box_outline_blank,
                color: color,
              ),
            ),
            IconButton(
              tooltip: 'Editar',
              onPressed: onEditar,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: onEliminar,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
