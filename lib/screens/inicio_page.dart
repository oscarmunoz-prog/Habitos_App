import 'package:flutter/material.dart';

import '../services/preferencias_service.dart';
import 'bienvenida_page.dart';
import 'principal_page.dart';

// Lee los datos guardados y decide qué pantalla mostrar:
// la bienvenida si es la primera vez, o la principal si ya hay nombre.
class InicioPage extends StatefulWidget {
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;

  const InicioPage({
    super.key,
    required this.onCambiarAjustes,
  });

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final _servicio = PreferenciasService();

  bool _cargando = true;
  String? _nombre;
  int _objetivo = 1;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // persistencia: leemos el nombre, el objetivo y los ajustes de tema y letra.
    final nombre = await _servicio.leerNombre();
    final objetivo = await _servicio.leerObjetivo();
    final temaOscuro = await _servicio.leerTemaOscuro();
    final tamanoLetra = await _servicio.leerTamanoLetra();

    if (!mounted) return;

    // Aplicamos a toda la app el tema y el tamaño de letra guardados.
    widget.onCambiarAjustes(temaOscuro, tamanoLetra);

    setState(() {
      _nombre = nombre;
      _objetivo = objetivo;
      _cargando = false;
    });
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

    final nombre = _nombre;

    // Primera ejecución: no hay nombre guardado, getString devolvió null.
    if (nombre == null) {
      return BienvenidaPage(onCambiarAjustes: widget.onCambiarAjustes);
    }

    // Pasamos el nombre y el objetivo al constructor de la principal.
    return PrincipalPage(
      nombre: nombre,
      objetivo: _objetivo,
      onCambiarAjustes: widget.onCambiarAjustes,
    );
  }
}