import 'package:flutter/material.dart';

import '../models/habito.dart';

// Fila de la lista de hábitos: casilla para marcarlo hoy, nombre,
// botón de editar y botón de borrar.
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
    return ListTile(
      leading: Checkbox(
        value: habito.completadoHoy(),
        activeColor: Color(habito.color),
        onChanged: (valor) => onMarcar(),
      ),
      title: Text(habito.nombre),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(habito.color)),
          IconButton(
            onPressed: onEditar,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: onBorrar,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}