import 'package:flutter/material.dart';

import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/habitos_service.dart';
import '../servicios/preferencias_service.dart';
import '../widgets/tarjeta_habito.dart';
import 'ajustes_page.dart';
import 'editar_habito_page.dart';
import 'estadisticas_page.dart';
import 'login_page.dart';

// Lista de hábitos de un usuario.
// El usuario normal la ve como su pantalla principal. El administrador la
// abre desde Administración para gestionar los hábitos de otro usuario
// (vistaAdmin: true), y entonces no se muestran Ajustes ni Cerrar sesión.
class HabitosPage extends StatefulWidget {
  final Usuario usuario;
  final void Function(bool temaOscuro, double tamanoLetra) onCambiarAjustes;
  final bool vistaAdmin;

  const HabitosPage({
    super.key,
    required this.usuario,
    required this.onCambiarAjustes,
    this.vistaAdmin = false,
  });

  @override
  State<HabitosPage> createState() => _HabitosPageState();
}

class _HabitosPageState extends State<HabitosPage> {
  final _habitosService = HabitosService();
  final _preferencias = PreferenciasService();

  bool _cargando = true;
  int _objetivo = 3;
  bool _ocultarCompletados = false;
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // PERSISTENCIA: solo pedimos los hábitos de este usuario.
  Future<void> _cargarDatos() async {
    final habitos = await _habitosService.obtenerPorUsuario(widget.usuario.id!);
    final objetivo = await _preferencias.leerObjetivo();
    final ocultarCompletados = await _preferencias.leerOcultarCompletados();

    if (!mounted) return;

    setState(() {
      _habitos = habitos;
      _objetivo = objetivo;
      _ocultarCompletados = ocultarCompletados;
      _cargando = false;
    });
  }

  // Marca o desmarca el hábito para el día de hoy.
  Future<void> _completar(Habito habito) async {
    final hoy = Habito.formatearDia(DateTime.now());
    setState(() {
      if (habito.completadoHoy()) {
        habito.fechasCompletado.remove(hoy);
      } else {
        habito.fechasCompletado.add(hoy);
      }
    });
    // PERSISTENCIA: el servicio guarda el hábito y actualiza sus estadísticas.
    await _habitosService.actualizar(habito);
  }

  // Abre el editor. Si habito es null, se crea uno nuevo.
  Future<void> _abrirEditor(Habito? habito) async {
    final resultado = await Navigator.push<Habito>(
      context,
      MaterialPageRoute<Habito>(
        builder: (context) => EditarHabitoPage(
          habito: habito,
          usuarioId: widget.usuario.id!,
        ),
      ),
    );

    // null: el usuario ha cancelado o ha vuelto sin guardar.
    if (!mounted || resultado == null) return;

    // PERSISTENCIA: si no tiene id es nuevo (insertar); si no, actualizar.
    if (resultado.id == null) {
      await _habitosService.insertar(resultado);
    } else {
      await _habitosService.actualizar(resultado);
    }
    await _cargarDatos();
  }

  // La tarjeta solo avisa de que se ha pulsado Eliminar. La pantalla pide
  // confirmación y, si se acepta, solicita el borrado al servicio.
  Future<void> _eliminar(Habito habito) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Quieres eliminar "${habito.nombre}"?'),
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

    await _habitosService.eliminar(habito.id!);
    await _cargarDatos();
  }

  void _abrirEstadisticas() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => EstadisticasPage(usuario: widget.usuario),
      ),
    );
  }

  Future<void> _abrirAjustes() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AjustesPage(
          usuario: widget.usuario,
          onCambiarAjustes: widget.onCambiarAjustes,
        ),
      ),
    );
    // Al volver recargamos, por si ha cambiado algún ajuste.
    await _cargarDatos();
  }

  Future<void> _cerrarSesion() async {
    await _preferencias.cerrarSesion();
    if (!mounted) return;

    // Volvemos al login quitando todas las pantallas anteriores.
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
    final completados = _habitos.where((h) => h.completadoHoy()).length;

    // Si el ajuste está activado, no mostramos los completados hoy.
    final visibles = _ocultarCompletados
        ? _habitos.where((h) => !h.completadoHoy()).toList()
        : _habitos;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vistaAdmin
              ? 'Hábitos de ${widget.usuario.usuario}'
              : 'Mis hábitos',
        ),
        actions: [
          IconButton(
            tooltip: 'Estadísticas',
            onPressed: _abrirEstadisticas,
            icon: const Icon(Icons.bar_chart),
          ),
          if (!widget.vistaAdmin) ...[
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
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          // SingleChildScrollView: la lista se desplaza si no cabe.
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${widget.usuario.nombre}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Hoy llevas $completados de $_objetivo hábitos'),
                  const SizedBox(height: 16),
                  if (_habitos.isEmpty)
                    const Text(
                      'Todavía no hay hábitos. Pulsa + para crear el primero.',
                    )
                  else if (visibles.isEmpty)
                    const Text('¡Has completado todos los hábitos de hoy!'),
                  // Una TarjetaHabito por hábito, cada una con sus datos y
                  // sus acciones sobre ese hábito concreto.
                  for (final habito in visibles)
                    TarjetaHabito(
                      key: ValueKey(habito.id),
                      nombre: habito.nombre,
                      color: Color(habito.color),
                      completado: habito.completadoHoy(),
                      onCompletar: () => _completar(habito),
                      onEditar: () => _abrirEditor(habito),
                      onEliminar: () => _eliminar(habito),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo hábito',
        onPressed: () => _abrirEditor(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
