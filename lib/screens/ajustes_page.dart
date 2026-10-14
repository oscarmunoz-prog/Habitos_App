import 'package:flutter/material.dart';

import '../services/preferencias_service.dart';
import 'inicio_page.dart';

// Tema claro u oscuro, tamaño de letra, ocultar completados y borrar datos.
class AjustesPage extends StatefulWidget {
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;

  const AjustesPage({
    super.key,
    required this.onCambiarAjustes,
  });

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  final _servicio = PreferenciasService();

  bool _cargando = true;
  bool _temaOscuro = false;
  double _tamanoLetra = 1.0;
  bool _ocultarCompletados = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // persistencia: leemos los ajustes guardados (bool y double).
    final temaOscuro = await _servicio.leerTemaOscuro();
    final tamanoLetra = await _servicio.leerTamanoLetra();
    final ocultarCompletados = await _servicio.leerOcultarCompletados();

    if (!mounted) return;

    setState(() {
      _temaOscuro = temaOscuro;
      _tamanoLetra = tamanoLetra;
      _ocultarCompletados = ocultarCompletados;
      _cargando = false;
    });
  }

  void _cambiarTema(bool valor) {
    setState(() {
      _temaOscuro = valor;
    });
    // Avisamos a MyApp para que cambie el tema de toda la app.
    widget.onCambiarAjustes(_temaOscuro, _tamanoLetra);
    // persistencia: guardamos el bool.
    _servicio.guardarTemaOscuro(valor);
  }

  void _cambiarTamanoLetra(double valor) {
    setState(() {
      _tamanoLetra = valor;
    });
    widget.onCambiarAjustes(_temaOscuro, _tamanoLetra);
    // persistencia: guardamos el double.
    _servicio.guardarTamanoLetra(valor);
  }

  void _cambiarOcultarCompletados(bool valor) {
    setState(() {
      _ocultarCompletados = valor;
    });
    // persistencia: guardamos el bool.
    _servicio.guardarOcultarCompletados(valor);
  }

  Future<void> _borrarDatos() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar datos'),
        content: const Text(
          'Se borrará todo y la app quedará como recién instalada. '
              '¿Quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // persistencia: borramos todas las claves guardadas.
    await _servicio.borrarTodo();

    if (!mounted) return;

    // Volvemos a InicioPage quitando todas las pantallas anteriores.
    // Como ya no hay nombre guardado, mostrará la bienvenida, y como no hay
    // ajustes guardados, aplicará el tema claro y la letra normal.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (context) => InicioPage(
          onCambiarAjustes: widget.onCambiarAjustes,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Tema oscuro'),
              value: _temaOscuro,
              onChanged: _cambiarTema,
            ),
            const SizedBox(height: 16),
            Text('Tamaño de letra: ${_tamanoLetra.toStringAsFixed(1)}'),
            Slider(
              value: _tamanoLetra,
              min: 0.8,
              max: 1.6,
              divisions: 8,
              onChanged: _cambiarTamanoLetra,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Ocultar hábitos completados hoy'),
              value: _ocultarCompletados,
              onChanged: _cambiarOcultarCompletados,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _borrarDatos,
              child: const Text('Borrar datos'),
            ),
          ],
        ),
      ),
    );
  }
}
