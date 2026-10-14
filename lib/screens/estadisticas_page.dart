import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../services/preferencias_service.dart';

// Racha y total de días de cada hábito, número de aperturas
// y fecha y hora de la última apertura.
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final _servicio = PreferenciasService();

  bool _cargando = true;
  int _aperturas = 0;
  String _ultimaApertura = '';
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // persistencia: leemos el contador int, la última apertura String
    // y los hábitos List<String> en JSON.
    final aperturas = await _servicio.leerAperturas();
    final ultimaApertura = await _servicio.leerUltimaApertura();
    final habitos = await _servicio.leerHabitos();

    if (!mounted) return;

    setState(() {
      _aperturas = aperturas;
      _ultimaApertura = _formatearFechaHora(ultimaApertura);
      _habitos = habitos;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Veces que se ha abierto la app: $_aperturas'),
            const SizedBox(height: 8),
            Text('Última apertura: $_ultimaApertura'),
            const SizedBox(height: 24),
            const Text(
              'Hábitos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            for (final habito in _habitos)
              ListTile(
                leading: Icon(Icons.circle, color: Color(habito.color)),
                title: Text(habito.nombre),
                subtitle: Text(
                  'Racha actual: ${habito.rachaActual()} días · '
                      'Total completados: ${habito.totalDias()} días',
                ),
              ),
          ],
        ),
      ),
    );
  }
}