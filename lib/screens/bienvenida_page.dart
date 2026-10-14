import 'package:flutter/material.dart';

import '../services/preferencias_service.dart';
import 'principal_page.dart';

// Solo aparece la primera vez. Pide el nombre y el objetivo diario.
class BienvenidaPage extends StatefulWidget {
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;

  const BienvenidaPage({
    super.key,
    required this.onCambiarAjustes,
  });

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  final _servicio = PreferenciasService();
  final _nombreController = TextEditingController();
  final _objetivoController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  Future<void> _empezar() async {
    final nombre = _nombreController.text.trim();
    // int.tryParse devuelve null si el texto no es un número.
    final objetivo = int.tryParse(_objetivoController.text.trim());

    if (nombre.isEmpty || objetivo == null || objetivo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe tu nombre y un objetivo mayor que 0')),
      );
      return;
    }

    // persistencia: guardamos el nombre (String) y el objetivo (int).
    // En las siguientes aperturas ya habrá nombre y se saltará esta pantalla.
    await _servicio.guardarUsuario(nombre, objetivo);

    if (!mounted) return;

    // pushReplacement cambia la bienvenida por la principal, así no se
    // puede volver atrás a esta pantalla.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PrincipalPage(
          onCambiarAjustes: widget.onCambiarAjustes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bienvenido a HabitosApp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Escribe tu nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _objetivoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objetivo diario de hábitos',
                hintText: 'Por ejemplo: 3',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _empezar,
              child: const Text('Empezar'),
            ),
          ],
        ),
      ),
    );
  }
}
