import 'package:flutter/material.dart';

// Muestra un dato estadístico: icono, valor y etiqueta.
// Sirve para cualquier dato (racha, días completados, aperturas...)
// sin cambiar su código: solo cambian los valores que recibe.
class DatoEstadistica extends StatelessWidget {
  // Texto que explica el dato, por ejemplo 'Racha actual'.
  final String etiqueta;
  // Valor que se muestra, por ejemplo '5 días'.
  final String valor;
  final IconData icono;
  // Color opcional. Si no se indica, se usa Colors.teal.
  final Color color;

  const DatoEstadistica({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    this.color = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icono, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(etiqueta, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
