import 'package:flutter/material.dart';

import '../servicios/preferencias_service.dart';
import '../servicios/usuarios_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';
import 'administracion_page.dart';
import 'habitos_page.dart';
import 'registro_page.dart';

// Inicio de sesión con usuario y contraseña.
class LoginPage extends StatefulWidget {
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;

  const LoginPage({
    super.key,
    required this.onCambiarAjustes,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarios = UsuariosService();
  final _preferencias = PreferenciasService();

  // La pantalla crea los controladores y se los pasa a CampoTextoApp.
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  // Mensaje de error que se muestra debajo de los campos.
  String? _mensaje;

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final nombreUsuario = _usuarioController.text.trim();
    final contrasena = _contrasenaController.text;

    if (nombreUsuario.isEmpty || contrasena.isEmpty) {
      setState(() {
        _mensaje = 'Escribe tu usuario y tu contraseña';
      });
      return;
    }

    // PERSISTENCIA: el servicio comprueba el usuario en la base de datos.
    final usuario = await _usuarios.iniciarSesion(nombreUsuario, contrasena);

    if (!mounted) return;

    if (usuario == null) {
      setState(() {
        _mensaje = 'Usuario o contraseña incorrectos';
      });
      return;
    }

    // Guardamos la sesión para no pedir la contraseña al volver a abrir.
    await _preferencias.guardarSesion(usuario.id!);

    if (!mounted) return;

    // El administrador va a su pantalla; el resto, a sus hábitos.
    // pushReplacement: así no se vuelve al login con la flecha atrás.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => usuario.esAdmin()
            ? AdministracionPage(
                administrador: usuario,
                onCambiarAjustes: widget.onCambiarAjustes,
              )
            : HabitosPage(
                usuario: usuario,
                onCambiarAjustes: widget.onCambiarAjustes,
              ),
      ),
    );
  }

  Future<void> _abrirRegistro() async {
    // El registro devuelve el nombre de usuario creado, o null si se cancela.
    final nuevoUsuario = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (context) => const RegistroPage(),
      ),
    );

    if (!mounted || nuevoUsuario == null) return;

    setState(() {
      _usuarioController.text = nuevoUsuario;
      _contrasenaController.clear();
      _mensaje = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta creada. Ya puedes iniciar sesión.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.task_alt, size: 72, color: Colors.teal),
            const SizedBox(height: 8),
            const Text(
              'HabitosApp',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            CampoTextoApp(
              etiqueta: 'Usuario',
              controller: _usuarioController,
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
              texto: 'Entrar',
              onPressed: _iniciarSesion,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _abrirRegistro,
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
