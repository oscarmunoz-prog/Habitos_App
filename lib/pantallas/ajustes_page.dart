import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import '../servicios/base_datos.dart';
import '../servicios/preferencias_service.dart';
import 'inicio_page.dart';

// Tema, tamaño de letra, objetivo diario y ocultar completados.
// El administrador, además, puede borrar todos los datos de la app.
class AjustesPage extends StatefulWidget {
  final Usuario usuario;
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;

  const AjustesPage({
    super.key,
    required this.usuario,
    required this.onCambiarAjustes,
  });

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  final _preferencias = PreferenciasService();

  bool _cargando = true;
  bool _temaOscuro = false;
  double _tamanoLetra = 1.0;
  bool _ocultarCompletados = false;
  int _objetivo = 3;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final temaOscuro = await _preferencias.leerTemaOscuro();
    final tamanoLetra = await _preferencias.leerTamanoLetra();
    final ocultarCompletados = await _preferencias.leerOcultarCompletados();
    final objetivo = await _preferencias.leerObjetivo();

    if (!mounted) return;

    setState(() {
      _temaOscuro = temaOscuro;
      _tamanoLetra = tamanoLetra;
      _ocultarCompletados = ocultarCompletados;
      _objetivo = objetivo;
      _cargando = false;
    });
  }

  void _cambiarTema(bool valor) {
    setState(() {
      _temaOscuro = valor;
    });
    widget.onCambiarAjustes(_temaOscuro, _tamanoLetra);
    _preferencias.guardarTemaOscuro(valor);
  }

  void _cambiarTamanoLetra(double valor) {
    setState(() {
      _tamanoLetra = valor;
    });
    widget.onCambiarAjustes(_temaOscuro, _tamanoLetra);
    _preferencias.guardarTamanoLetra(valor);
  }

  void _cambiarOcultarCompletados(bool valor) {
    setState(() {
      _ocultarCompletados = valor;
    });
    _preferencias.guardarOcultarCompletados(valor);
  }

  void _cambiarObjetivo(int valor) {
    if (valor < 1) return;
    setState(() {
      _objetivo = valor;
    });
    _preferencias.guardarObjetivo(valor);
  }

  Future<void> _borrarDatos() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar todos los datos'),
        content: const Text(
          'Se borrarán todos los usuarios, hábitos, estadísticas y ajustes. '
          'Solo quedará el administrador. ¿Quieres continuar?',
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

    // PERSISTENCIA: borramos la base de datos y SharedPreferences.
    await BaseDatos.borrarTodo();
    await _preferencias.borrarTodo();

    if (!mounted) return;

    // Volvemos a InicioPage, que mostrará el login con el tema por defecto.
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
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 16),
                  const Text('Objetivo diario de hábitos'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _cambiarObjetivo(_objetivo - 1),
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$_objetivo',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _cambiarObjetivo(_objetivo + 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  // Solo el administrador puede borrar todos los datos.
                  if (widget.usuario.esAdmin()) ...[
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _borrarDatos,
                      child: const Text('Borrar todos los datos'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
