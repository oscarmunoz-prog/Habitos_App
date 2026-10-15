import 'package:flutter/material.dart';

import '../models/habito.dart';

// Ficha de un hábito: casilla para marcarlo hoy, icono, nombre, color,
// estado y botones para editar y borrar.
// Recibe desde fuera el hábito y las funciones de cada botón.
class HabitoTile extends StatelessWidget {
  final Habito habito;
  final VoidCallback onMarcar;
  final VoidCallback onEditar;
  final VoidCallback onBorrar;

  const HabitoTile({
    super.key,
    required this.habito,
    required this.onMarcar,
    required this.onEditar,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habito.color);
    final hecho = habito.completadoHoy();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: hecho,
                  activeColor: color,
                  onChanged: (valor) => onMarcar(),
                ),
                Icon(Icons.task_alt, color: color, size: 32),
                const SizedBox(width: 12),
                // Expanded hace que los textos usen el espacio que queda
                // en la fila sin salirse de la pantalla.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habito.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Color: ${habito.nombreColor()}'),
                      Text(hecho ? 'Completado hoy' : 'Pendiente'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onEditar,
                  child: const Text('Editar hábito'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onBorrar,
                  child: const Text('Borrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}