import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
import '../servicios/usuarios_service.dart';
import 'administracion_page.dart';
import 'habitos_page.dart';
import 'login_page.dart';

// Primera pantalla. Lee los ajustes y la sesión guardada y decide:
//  - nadie ha iniciado sesión -> LoginPage
//  - administrador -> AdministracionPage
//  - usuario normal -> HabitosPage
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
  final _preferencias = PreferenciasService();
  final _usuarios = UsuariosService();

  bool _cargando = true;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final temaOscuro = await _preferencias.leerTemaOscuro();
    final tamanoLetra = await _preferencias.leerTamanoLetra();
    final usuarioId = await _preferencias.leerSesion();

    // Si hay sesión guardada, buscamos ese usuario en la base de datos.
    Usuario? usuario;
    if (usuarioId != null) {
      usuario = await _usuarios.obtenerPorId(usuarioId);
    }

    if (!mounted) return;

    widget.onCambiarAjustes(temaOscuro, tamanoLetra);

    setState(() {
      _usuario = usuario;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text('HabitosApp')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final usuario = _usuario;

    if (usuario == null) {
      return LoginPage(onCambiarAjustes: widget.onCambiarAjustes);
    }

    if (usuario.esAdmin()) {
      return AdministracionPage(
        administrador: usuario,
        onCambiarAjustes: widget.onCambiarAjustes,
      );
    }

    return HabitosPage(
      usuario: usuario,
      onCambiarAjustes: widget.onCambiarAjustes,
    );
  }
}
