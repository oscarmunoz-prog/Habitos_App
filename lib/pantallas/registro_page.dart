import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import '../servicios/usuarios_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';

// Registro de un usuario nuevo. Siempre se crea con el rol 'usuario'.
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _usuarios = UsuariosService();

  final _usuarioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _contrasenaController = TextEditingController();

  String? _mensaje;

  @override
  void dispose() {
    _usuarioController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
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

    if (!email.contains('@')) {
      setState(() {
        _mensaje = 'El email no es válido';
      });
      return;
    }

    // PERSISTENCIA: comprobamos que el nombre de usuario no exista ya.
    final existente = await _usuarios.buscarPorNombreUsuario(nombreUsuario);
    if (!mounted) return;
    if (existente != null) {
      setState(() {
        _mensaje = 'Ese nombre de usuario ya existe';
      });
      return;
    }

    final usuario = Usuario(
      usuario: nombreUsuario,
      nombre: nombre,
      apellidos: apellidos,
      email: email,
      contrasena: contrasena,
      // La fecha de creación se asigna automáticamente.
      fechaCreacion: DateTime.now().toIso8601String(),
      rol: Usuario.rolUsuario,
    );

    // PERSISTENCIA: guardamos el usuario en la tabla 'usuarios'.
    await _usuarios.insertar(usuario);

    if (!mounted) return;

    // Volvemos al login y le devolvemos el nombre de usuario creado.
    Navigator.pop(context, nombreUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(
              etiqueta: 'Usuario',
              controller: _usuarioController,
            ),
            CampoTextoApp(
              etiqueta: 'Nombre',
              controller: _nombreController,
            ),
            CampoTextoApp(
              etiqueta: 'Apellidos',
              controller: _apellidosController,
            ),
            CampoTextoApp(
              etiqueta: 'Email',
              controller: _emailController,
            ),
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: _contrasenaController,
              ocultarTexto: true,
            ),
            if (_mensaje != null) ...[
              Text(_mensaje!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],
            BotonPrincipal(
              texto: 'Registrarse',
              onPressed: _registrar,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ya tengo cuenta: volver al inicio de sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
