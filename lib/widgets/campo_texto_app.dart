import 'package:flutter/material.dart';

// Campo de texto con el diseño común de toda la app.
// La pantalla crea y gestiona el controlador y se lo pasa al componente.
class CampoTextoApp extends StatelessWidget {
  // Texto de la etiqueta, por ejemplo 'Usuario' o 'Contraseña'.
  final String etiqueta;
  // Controlador que usará el campo (lo crea la pantalla).
  final TextEditingController controller;
  // true para ocultar lo que se escribe (contraseñas).
  final bool ocultarTexto;

  const CampoTextoApp({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.ocultarTexto = false,
  });

  @override
  Widget build(BuildContext context) {
    // El Padding inferior hace que todos los campos queden igual de separados.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: ocultarTexto,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
