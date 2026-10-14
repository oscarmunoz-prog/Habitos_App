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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // PERSISTENCIA: leemos el nombre y los ajustes de tema y letra.
    final nombre = await _servicio.leerNombre();
    final temaOscuro = await _servicio.leerTemaOscuro();
    final tamanoLetra = await _servicio.leerTamanoLetra();

    if (!mounted) return;

    // Aplicamos a toda la app el tema y el tamaño de letra guardados.
    widget.onCambiarAjustes(temaOscuro, tamanoLetra);

    setState(() {
      _nombre = nombre;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Indicador de carga mientras se leen los datos.
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Primera ejecución: no hay nombre guardado (getString devolvió null).
    if (_nombre == null) {
      return BienvenidaPage(onCambiarAjustes: widget.onCambiarAjustes);
    }

    return PrincipalPage(onCambiarAjustes: widget.onCambiarAjustes);
  }
}