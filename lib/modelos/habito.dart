import 'dart:convert';

// Datos de un hábito (tabla 'habitos').
class Habito {
  // Los tres colores que se pueden elegir y su nombre para mostrarlo.
  static const Map<int, String> colores = {
    0xFF2196F3: 'Azul',
    0xFF4CAF50: 'Verde',
    0xFFFF9800: 'Naranja',
  };

  // id es null hasta que el hábito se guarda en la base de datos.
  final int? id;
  // Usuario al que pertenece el hábito.
  final int usuarioId;
  final String nombre;
  // El color se guarda como número (por ejemplo 0xFF2196F3).
  final int color;
  // Días en los que se ha completado, con el formato 'aaaa-mm-dd'.
  final List<String> fechasCompletado;

  const Habito({
    this.id,
    required this.usuarioId,
    required this.nombre,
    required this.color,
    required this.fechasCompletado,
  });

  // PERSISTENCIA: una columna de SQLite no puede guardar una lista, así que
  // guardamos las fechas como texto JSON con jsonEncode.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'color': color,
      'fechas_completado': jsonEncode(fechasCompletado),
    };
  }

  // PERSISTENCIA: al leer la fila, recuperamos la lista con jsonDecode.
  factory Habito.fromMap(Map<String, dynamic> mapa) {
    return Habito(
      id: mapa['id'],
      usuarioId: mapa['usuario_id'],
      nombre: mapa['nombre'],
      color: mapa['color'],
      fechasCompletado: List<String>.from(jsonDecode(mapa['fechas_completado'])),
    );
  }

  // Nombre del color del hábito, por ejemplo 'Azul'.
  String nombreColor() {
    return colores[color] ?? 'Otro';
  }

  // Convierte una fecha en texto 'aaaa-mm-dd', por ejemplo '2026-11-02'.
  static String formatearDia(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }

  bool completadoHoy() {
    return fechasCompletado.contains(formatearDia(DateTime.now()));
  }

  // Número de días distintos en los que se ha completado.
  int totalDias() {
    return fechasCompletado.toSet().length;
  }

  // Días seguidos completados. Si hoy aún no está marcado, empezamos a
  // contar desde ayer, porque todavía queda día para hacerlo.
  int rachaActual() {
    var dia = DateTime.now();
    if (!completadoHoy()) {
      dia = DateTime(dia.year, dia.month, dia.day - 1);
    }

    var racha = 0;
    while (fechasCompletado.contains(formatearDia(dia))) {
      racha++;
      dia = DateTime(dia.year, dia.month, dia.day - 1);
    }
    return racha;
  }
}
