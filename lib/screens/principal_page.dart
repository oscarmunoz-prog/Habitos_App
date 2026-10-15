import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../widgets/habito_tile.dart';
import 'ajustes_page.dart';
import 'editar_habito_page.dart';
import 'estadisticas_page.dart';

// Saluda al usuario, muestra el progreso del día y la lista de hábitos.
class PrincipalPage extends StatefulWidget {
  // Datos que recibe de la pantalla anterior a través del constructor.
  final String nombre;
  final int objetivo;
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;

  const PrincipalPage({
    super.key,
    required this.nombre,
    required this.objetivo,
    required this.onCambiarAjustes,
  });

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  final _servicio = PreferenciasService();

  bool _cargando = true;
  bool _ocultarCompletados = false;
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // persistencia: leemos los datos guardados a través del servicio.
  // El nombre y el objetivo no hace falta leerlos, llegan por el constructor.
  Future<void> _cargarDatos() async {
    final ocultarCompletados = await _servicio.leerOcultarCompletados();
    final habitos = await _servicio.leerHabitos();

    if (!mounted) return;

    setState(() {
      _ocultarCompletados = ocultarCompletados;
      _habitos = habitos;
      _cargando = false;
    });
  }

  // Marca o desmarca el hábito para el día de hoy.
  void _marcarHabito(Habito habito) {
    final hoy = Habito.formatearDia(DateTime.now());
    setState(() {
      if (habito.completadoHoy()) {
        habito.fechasCompletado.remove(hoy);
      } else {
        habito.fechasCompletado.add(hoy);
      }
    });
    // persistencia: guardamos la lista para que se recuerde al cerrar la app.
    _servicio.guardarHabitos(_habitos);
  }

  // Abre el editor. Si habito es null, se crea uno nuevo.
  Future<void> _abrirEditor(Habito? habito) async {
    final resultado = await Navigator.push<Habito>(
      context,
      MaterialPageRoute<Habito>(
        builder: (context) => EditarHabitoPage(habito: habito),
      ),
    );

    // null = el usuario ha cancelado o ha vuelto sin guardar.
    if (!mounted || resultado == null) return;

    setState(() {
      // Si ya existía un hábito con ese id lo sustituimos; si no, lo añadimos.
      final posicion = _habitos.indexWhere((h) => h.id == resultado.id);
      if (posicion == -1) {
        _habitos.add(resultado);
      } else {
        _habitos[posicion] = resultado;
      }
    });
    // persistencia: guardamos la lista con el hábito nuevo o editado.
    await _servicio.guardarHabitos(_habitos);
  }

  Future<void> _borrarHabito(Habito habito) async {
    // showDialog devuelve el valor que pasamos a Navigator.pop.
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar hábito'),
        content: Text('¿Quieres borrar "${habito.nombre}"?'),
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

    if (!mounted || confirmar != true) return;

    setState(() {
      _habitos.remove(habito);
    });
    // peristencia: guardamos la lista sin el hábito borrado.
    await _servicio.guardarHabitos(_habitos);
  }

  void _abrirEstadisticas() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const EstadisticasPage(),
      ),
    );
  }

  Future<void> _abrirAjustes() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AjustesPage(
          onCambiarAjustes: widget.onCambiarAjustes,
        ),
      ),
    );
    // Al volver recargamos, por si ha cambiado "ocultar completados".
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    // Indicador de carga mientras se leen los datos.
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text('HabitosApp')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final completados = _habitos.where((h) => h.completadoHoy()).length;

    // Si el ajuste está activado, no mostramos los completados hoy.
    final visibles = _ocultarCompletados
        ? _habitos.where((h) => !h.completadoHoy()).toList()
        : _habitos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitosApp'),
        actions: [
          IconButton(
            onPressed: _abrirEstadisticas,
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            onPressed: _abrirAjustes,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${widget.nombre}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tu objetivo diario: ${widget.objetivo} hábitos'),
            const SizedBox(height: 4),
            Text(
              'Hoy llevas $completados de ${widget.objetivo} hábitos',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (_habitos.isEmpty) const Text('Todavía no tienes hábitos.'),
            for (final habito in visibles)
              HabitoTile(
                habito: habito,
                onMarcar: () => _marcarHabito(habito),
                onEditar: () => _abrirEditor(habito),
                onBorrar: () => _borrarHabito(habito),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirEditor(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}