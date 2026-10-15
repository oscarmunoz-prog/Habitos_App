// datos de un hábito: identificador, nombre, color y fechas completadas.
class Habito {
  final String id;
  final String nombre;
  // El color se guarda como número.
  // Para dibujarlo usamos Color.
  final int color;
  // Días en los que se ha completado, con el formato 'aaaa-mm-dd'.
  final List<String> fechasCompletado;

  const Habito({
    required this.id,
    required this.nombre,
    required this.color,
    required this.fechasCompletado,
  });

  // Los tres colores que se pueden elegir y su nombre para mostrarlo.
  static const Map<int, String> colores = {
    0xFF2196F3: 'Azul',
    0xFF4CAF50: 'Verde',
    0xFFFF9800: 'Naranja',
  };

  // Nombre del color del hábito, por ejemplo 'Azul'.
  String nombreColor() {
    return colores[color] ?? 'Otro';
  }

  // persistencia: SharedPreferences no guarda objetos, solo tipos básicos.
  // toJson convierte el hábito en un Map que después pasaremos a texto
  // con jsonEncode.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'fechasCompletado': fechasCompletado,
    };
  }

  // persistencia: crea un Habito a partir del Map que devuelve jsonDecode.
  // jsonDecode devuelve la lista como List<dynamic>, por eso usamos
  // List<String>.from para convertirla.
  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['id'],
      nombre: json['nombre'],
      color: json['color'],
      fechasCompletado: List<String>.from(json['fechasCompletado']),
    );
  }

  // Convierte una fecha en texto 'aaaa-mm-dd', por ejemplo '2026-10-14'.
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

  // días seguidos completados. Si hoy aún no está marcado, empezamos a
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