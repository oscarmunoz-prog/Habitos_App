import 'package:flutter/material.dart';

import '../models/habito.dart';

// Pantalla para crear o editar un hábito.
// Si recibe un hábito lo edita; si recibe null, crea uno nuevo.
// Al guardar devuelve el Habito con Navigator.pop.
class EditarHabitoPage extends StatefulWidget {
  final Habito? habito;

  const EditarHabitoPage({
    super.key,
    required this.habito,
  });

  @override
  State<EditarHabitoPage> createState() => _EditarHabitoPageState();
}

class _EditarHabitoPageState extends State<EditarHabitoPage> {
  // Colores que se pueden elegir.
  final List<int> _colores = [
    0xFF2196F3, // azul
    0xFF4CAF50, // verde
    0xFFFF9800, // naranja
    0xFFF44336, // rojo
    0xFF9C27B0, // morado
  ];

  late final TextEditingController _nombreController;
  late int _color;

  @override
  void initState() {
    super.initState();
    // Si editamos, los campos empiezan con los datos del hábito.
    _nombreController = TextEditingController(
      text: widget.habito?.nombre ?? '',
    );
    _color = widget.habito?.color ?? _colores[0];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) return;

    final habito = Habito(
      // Si es nuevo, usamos la fecha en milisegundos como id único.
      id: widget.habito?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      color: _color,
      // Si editamos, conservamos los días que ya estaban completados.
      fechasCompletado: widget.habito?.fechasCompletado ?? [],
    );
    Navigator.pop(context, habito);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habito == null ? 'Nuevo hábito' : 'Editar hábito'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Por ejemplo: Beber agua',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final color in _colores)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _color = color;
                      });
                    },
                    // El color elegido se muestra con un círculo marcado.
                    icon: Icon(
                      color == _color ? Icons.check_circle : Icons.circle,
                      color: Color(color),
                      size: 36,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardar,
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
