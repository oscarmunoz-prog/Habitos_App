import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
import '../servicios/usuarios_service.dart';
import 'ajustes_page.dart';
import 'editar_usuario_page.dart';
import 'estadisticas_page.dart';
import 'habitos_page.dart';
import 'login_page.dart';

// Pantalla del administrador. Desde aquí gestiona:
//  - usuarios: ver, crear, editar y eliminar;
//  - hábitos de cada usuario (abre HabitosPage en modo administrador);
//  - estadísticas de todos los hábitos.
class AdministracionPage extends StatefulWidget {
  final Usuario administrador;
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;

  const AdministracionPage({
    super.key,
    required this.administrador,
    required this.onCambiarAjustes,
  });

  @override
  State<AdministracionPage> createState() => _AdministracionPageState();
}

class _AdministracionPageState extends State<AdministracionPage> {
  final _usuariosService = UsuariosService();
  final _preferencias = PreferenciasService();

  bool _cargando = true;
  List<Usuario> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final usuarios = await _usuariosService.obtenerTodos();
    if (!mounted) return;
    setState(() {
      _usuarios = usuarios;
      _cargando = false;
    });
  }

  // Abre el formulario de usuario. Si usuario es null, se crea uno nuevo.
  Future<void> _abrirEditorUsuario(Usuario? usuario) async {
    final resultado = await Navigator.push<Usuario>(
      context,
      MaterialPageRoute<Usuario>(
        builder: (context) => EditarUsuarioPage(usuario: usuario),
      ),
    );

    if (!mounted || resultado == null) return;

    if (resultado.id == null) {
      await _usuariosService.insertar(resultado);
    } else {
      await _usuariosService.actualizar(resultado);
    }
    await _cargarDatos();
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Quieres eliminar a "${usuario.usuario}"? '
          'También se borrarán sus hábitos y estadísticas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true) return;

    await _usuariosService.eliminar(usuario.id!);
    await _cargarDatos();
  }

  void _verHabitos(Usuario usuario) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => HabitosPage(
          usuario: usuario,
          onCambiarAjustes: widget.onCambiarAjustes,
          vistaAdmin: true,
        ),
      ),
    );
  }

  void _abrirEstadisticas() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        // usuario: null -> estadísticas de todos los hábitos.
        builder: (context) => const EstadisticasPage(usuario: null),
      ),
    );
  }

  void _abrirAjustes() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AjustesPage(
          usuario: widget.administrador,
          onCambiarAjustes: widget.onCambiarAjustes,
        ),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await _preferencias.cerrarSesion();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (context) => LoginPage(
          onCambiarAjustes: widget.onCambiarAjustes,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        actions: [
          IconButton(
            tooltip: 'Estadísticas',
            onPressed: _abrirEstadisticas,
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            tooltip: 'Ajustes',
            onPressed: _abrirAjustes,
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${widget.administrador.nombre}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Usuarios',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (final usuario in _usuarios)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          usuario.esAdmin()
                              ? Icons.admin_panel_settings
                              : Icons.person,
                        ),
                        title: Text('${usuario.nombre} ${usuario.apellidos}'),
                        subtitle: Text(
                          '${usuario.usuario} · ${usuario.email} · ${usuario.rol}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Ver hábitos',
                              onPressed: () => _verHabitos(usuario),
                              icon: const Icon(Icons.list),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () => _abrirEditorUsuario(usuario),
                              icon: const Icon(Icons.edit),
                            ),
                            // El administrador no puede eliminarse a sí mismo.
                            if (usuario.id != widget.administrador.id)
                              IconButton(
                                tooltip: 'Eliminar',
                                onPressed: () => _eliminarUsuario(usuario),
                                icon: const Icon(Icons.delete),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo usuario',
        onPressed: () => _abrirEditorUsuario(null),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
