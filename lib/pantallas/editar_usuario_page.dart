import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import '../servicios/usuarios_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';

// Formulario del administrador para crear o editar un usuario.
// Reutiliza CampoTextoApp y BotonPrincipal, igual que el registro.
// Al guardar devuelve el Usuario y Administración lo guarda.
class EditarUsuarioPage extends StatefulWidget {
  final Usuario? usuario;

  const EditarUsuarioPage({
    super.key,
    required this.usuario,
  });

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final _usuariosService = UsuariosService();

  late final TextEditingController _usuarioController;
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _emailController;
  late final TextEditingController _contrasenaController;
  late bool _esAdmin;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    final usuario = widget.usuario;
    _usuarioController = TextEditingController(text: usuario?.usuario ?? '');
    _nombreController = TextEditingController(text: usuario?.nombre ?? '');
    _apellidosController =
        TextEditingController(text: usuario?.apellidos ?? '');
    _emailController = TextEditingController(text: usuario?.email ?? '');
    _contrasenaController =
        TextEditingController(text: usuario?.contrasena ?? '');
    _esAdmin = usuario?.esAdmin() ?? false;
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombreUsuario = _usuarioController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final email = _emailController.text.trim();
    final contrasena = _contrasenaController.text;

    if (nombreUsuario.isEmpty ||
        nombre.isEmpty ||
        apellidos.isEmpty ||
        email.isEmpty ||
        contrasena.isEmpty) {
      setState(() {
        _mensaje = 'Rellena todos los campos';
      });
      return;
    }

    // El nombre de usuario no puede estar ocupado por otro usuario.
    final existente =
        await _usuariosService.buscarPorNombreUsuario(nombreUsuario);
    if (!mounted) return;
    if (existente != null && existente.id != widget.usuario?.id) {
      setState(() {
        _mensaje = 'Ese nombre de usuario ya existe';
      });
      return;
    }

    final resultado = Usuario(
      id: widget.usuario?.id,
      usuario: nombreUsuario,
      nombre: nombre,
      apellidos: apellidos,
      email: email,
      contrasena: contrasena,
      // Al editar conservamos la fecha original; al crear, la de ahora.
      fechaCreacion:
          widget.usuario?.fechaCreacion ?? DateTime.now().toIso8601String(),
      rol: _esAdmin ? Usuario.rolAdmin : Usuario.rolUsuario,
    );
    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario == null ? 'Nuevo usuario' : 'Editar usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Usuario', controller: _usuarioController),
            CampoTextoApp(etiqueta: 'Nombre', controller: _nombreController),
            CampoTextoApp(
              etiqueta: 'Apellidos',
              controller: _apellidosController,
            ),
            CampoTextoApp(etiqueta: 'Email', controller: _emailController),
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: _contrasenaController,
              ocultarTexto: true,
            ),
            SwitchListTile(
              title: const Text('Administrador'),
              value: _esAdmin,
              onChanged: (valor) {
                setState(() {
                  _esAdmin = valor;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_mensaje != null) ...[
              Text(_mensaje!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],
            BotonPrincipal(texto: 'Guardar', onPressed: _guardar),
            const SizedBox(height: 8),
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
