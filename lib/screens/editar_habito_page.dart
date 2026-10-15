import 'package:flutter/material.dart';

import '../models/habito.dart';

// Pantalla para crear o editar un hábito.
// Si recibe un hábito lo edita y si recibe null crea uno nuevo.
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
  late final TextEditingController _nombreController;
  late int _color;

  @override
  void initState() {
    super.initState();
    // El campo empieza con el nombre recibido (vacío si es nuevo).
    _nombreController = TextEditingController(
      text: widget.habito?.nombre ?? '',
    );
    _color = widget.habito?.color ?? Habito.colores.keys.first;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _elegirColor(int color) {
    setState(() {
      _color = color;
    });
  }

  void _guardar() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) return;

    final habito = Habito(
      // Si es nuevo usamos la fecha en milisegundos como id único.
      id: widget.habito?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      color: _color,
      // Si editamos conservamos los días que ya estaban completados.
      fechasCompletado: widget.habito?.fechasCompletado ?? [],
    );
    // pop cierra el editor y entrega el resultado a la principal.
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
                labelText: 'Nombre del hábito',
                hintText: 'Por ejemplo: Beber agua',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Un botón por cada color agrupados en una Row.
            Row(
              children: [
                for (final color in Habito.colores.keys)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(color),
                          foregroundColor: Colors.white,
                          // El color elegido se marca con un borde grueso.
                          side: color == _color
                              ? const BorderSide(color: Colors.black, width: 3)
                              : null,
                        ),
                        onPressed: () => _elegirColor(color),
                        child: Text(Habito.colores[color]!),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Color seleccionado: ${Habito.colores[_color] ?? 'Otro'}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardar,
              child: const Text('Guardar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              // Cancelar cierra sin devolver nada (resultado null).
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}