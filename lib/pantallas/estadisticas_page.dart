import 'package:flutter/material.dart';

import '../modelos/estadistica.dart';
import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/estadisticas_service.dart';
import '../servicios/habitos_service.dart';
import '../servicios/preferencias_service.dart';
import '../servicios/usuarios_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/dato_estadistica.dart';

// Estadísticas de cada hábito.
//  - Con un usuario: solo sus hábitos (rol usuario).
//  - Con usuario null: todos los hábitos, y el administrador puede crear,
//    editar y eliminar filas de la tabla 'estadisticas'.
class EstadisticasPage extends StatefulWidget {
  final Usuario? usuario;

  const EstadisticasPage({
    super.key,
    required this.usuario,
  });

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final _habitosService = HabitosService();
  final _estadisticasService = EstadisticasService();
  final _usuariosService = UsuariosService();
  final _preferencias = PreferenciasService();

  bool _cargando = true;
  int _aperturas = 0;
  String _ultimaApertura = 'Sin datos';
  List<Habito> _habitos = [];
  // Estadística de cada hábito, buscada por el id del hábito.
  Map<int, Estadistica> _estadisticas = {};
  // Nombre de usuario de cada id, para saber de quién es cada hábito.
  Map<int, String> _propietarios = {};

  bool get _modoAdmin => widget.usuario == null;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final usuario = widget.usuario;
    final List<Habito> habitos;

    if (usuario == null) {
      habitos = await _habitosService.obtenerTodos();
    } else {
      habitos = await _habitosService.obtenerPorUsuario(usuario.id!);
      // La racha depende del día de hoy, así que la recalculamos al entrar.
      for (final habito in habitos) {
        await _estadisticasService.guardarParaHabito(habito);
      }
    }

    final estadisticas = await _estadisticasService.obtenerTodas();
    final usuarios = await _usuariosService.obtenerTodos();
    final aperturas = await _preferencias.leerAperturas();
    final ultimaApertura = await _preferencias.leerUltimaApertura();

    if (!mounted) return;

    setState(() {
      _habitos = habitos;
      _estadisticas = {for (final e in estadisticas) e.habitoId: e};
      _propietarios = {for (final u in usuarios) u.id!: u.usuario};
      _aperturas = aperturas;
      _ultimaApertura = _formatearFechaHora(ultimaApertura);
      _cargando = false;
    });
  }

  // Convierte el texto guardado en 'dd/mm/aaaa hh:mm'.
  String _formatearFechaHora(String? texto) {
    if (texto == null) return 'Sin datos';
    final fecha = DateTime.parse(texto);
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} $hora:$minuto';
  }

  // ---------- Acciones del administrador ----------

  // Crea (o recalcula) la estadística de un hábito.
  Future<void> _crearEstadistica(Habito habito) async {
    await _estadisticasService.guardarParaHabito(habito);
    await _cargarDatos();
  }

  Future<void> _recalcularTodas() async {
    for (final habito in _habitos) {
      await _estadisticasService.guardarParaHabito(habito);
    }
    await _cargarDatos();
  }

  Future<void> _editarEstadistica(Estadistica estadistica) async {
    final rachaController = TextEditingController(
      text: estadistica.rachaActual.toString(),
    );
    final totalController = TextEditingController(
      text: estadistica.totalCompletados.toString(),
    );

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar estadística'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CampoTextoApp(etiqueta: 'Racha actual', controller: rachaController),
            CampoTextoApp(
              etiqueta: 'Días completados',
              controller: totalController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    // No llamamos a dispose aquí: el diálogo todavía se está cerrando con
    // su animación y seguiría usando los controladores.
    final racha = int.tryParse(rachaController.text.trim());
    final total = int.tryParse(totalController.text.trim());

    if (!mounted || guardar != true) return;

    if (racha == null || total == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los valores tienen que ser números')),
      );
      return;
    }

    await _estadisticasService.actualizar(
      Estadistica(
        id: estadistica.id,
        habitoId: estadistica.habitoId,
        rachaActual: racha,
        totalCompletados: total,
      ),
    );
    await _cargarDatos();
  }

  Future<void> _eliminarEstadistica(Estadistica estadistica) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar estadística'),
        content: const Text('¿Quieres eliminar esta fila de estadísticas?'),
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

    await _estadisticasService.eliminar(estadistica.id!);
    await _cargarDatos();
  }

  // ---------- Interfaz ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          if (_modoAdmin)
            IconButton(
              tooltip: 'Recalcular todas',
              onPressed: _recalcularTodas,
              icon: const Icon(Icons.refresh),
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
                  const Text(
                    'Uso de la app',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // El mismo componente sirve para datos distintos.
                  Row(
                    children: [
                      Expanded(
                        child: DatoEstadistica(
                          etiqueta: 'Aperturas',
                          valor: '$_aperturas',
                          icono: Icons.open_in_new,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DatoEstadistica(
                          etiqueta: 'Última apertura',
                          valor: _ultimaApertura,
                          icono: Icons.access_time,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hábitos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_habitos.isEmpty)
                    const Text('Todavía no hay hábitos.'),
                  for (final habito in _habitos) _construirHabito(habito),
                ],
              ),
            ),
    );
  }

  // Bloque de un hábito: su nombre arriba y sus dos datos debajo, para
  // que se vea claramente a qué hábito pertenece cada dato.
  Widget _construirHabito(Habito habito) {
    final estadistica = _estadisticas[habito.id];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: Color(habito.color), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _modoAdmin
                      ? '${habito.nombre} (${_propietarios[habito.usuarioId] ?? '?'})'
                      : habito.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (estadistica == null)
            Row(
              children: [
                const Text('Sin estadísticas'),
                if (_modoAdmin)
                  TextButton(
                    onPressed: () => _crearEstadistica(habito),
                    child: const Text('Crear'),
                  ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: DatoEstadistica(
                    etiqueta: 'Racha actual',
                    valor: '${estadistica.rachaActual} días',
                    icono: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DatoEstadistica(
                    etiqueta: 'Días completados',
                    valor: '${estadistica.totalCompletados}',
                    icono: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (_modoAdmin)
              Row(
                children: [
                  TextButton(
                    onPressed: () => _editarEstadistica(estadistica),
                    child: const Text('Editar'),
                  ),
                  TextButton(
                    onPressed: () => _eliminarEstadistica(estadistica),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
