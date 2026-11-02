import 'package:flutter/material.dart';

// Botón de las acciones principales.
// Cada pantalla le pasa su texto y la acción que debe ejecutar.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  // Función que se ejecuta al pulsar el botón.
  final VoidCallback onPressed;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // SizedBox con width: double.infinity hace que ocupe todo el ancho.
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          texto,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
