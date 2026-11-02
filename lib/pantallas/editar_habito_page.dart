import 'package:flutter/material.dart';

import '../modelos/habito.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';

// Pantalla para crear o editar un hábito.
// Si recibe un hábito lo edita; si recibe null, crea uno nuevo.
// Al guardar devuelve el Habito con Navigator.pop y la lista lo guarda.
class EditarHabitoPage extends StatefulWidget {
  final Habito? habito;
  // Usuario al que pertenecerá el hábito si es nuevo.
  final int usuarioId;

  const EditarHabitoPage({
    super.key,
    required this.habito,
    required this.usuarioId,
  });

  @override
  State<EditarHabitoPage> createState() => _EditarHabitoPageState();
}

class _EditarHabitoPageState extends State<EditarHabitoPage> {
  late final TextEditingController _nombreController;
  late int _color;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    // Al crear: nombre vacío y el primer color. Al editar: sus datos.
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
    if (nombre.isEmpty) {
      setState(() {
        _mensaje = 'Escribe un nombre para el hábito';
      });
      return;
    }

    final habito = Habito(
      // Si es nuevo, el id es null y lo asignará la base de datos.
      id: widget.habito?.id,
      usuarioId: widget.habito?.usuarioId ?? widget.usuarioId,
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
          children: [
            CampoTextoApp(
              etiqueta: 'Nombre del hábito',
              controller: _nombreController,
            ),
            const Text(
              'Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Un botón por cada color predefinido, agrupados en una Row.
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
            if (_mensaje != null) ...[
              Text(_mensaje!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],
            BotonPrincipal(
              texto: 'Guardar',
              onPressed: _guardar,
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
