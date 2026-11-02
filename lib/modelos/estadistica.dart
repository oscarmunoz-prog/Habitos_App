// Estadísticas de un hábito (tabla 'estadisticas').
// Cada hábito tiene una fila con su racha actual y su total de días.
class Estadistica {
  final int? id;
  final int habitoId;
  final int rachaActual;
  final int totalCompletados;

  const Estadistica({
    this.id,
    required this.habitoId,
    required this.rachaActual,
    required this.totalCompletados,
  });

  // PERSISTENCIA: convierte el objeto en un Map con las columnas de la tabla.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habito_id': habitoId,
      'racha_actual': rachaActual,
      'total_completados': totalCompletados,
    };
  }

  // PERSISTENCIA: crea una Estadistica a partir de una fila de la tabla.
  factory Estadistica.fromMap(Map<String, dynamic> mapa) {
    return Estadistica(
      id: mapa['id'],
      habitoId: mapa['habito_id'],
      rachaActual: mapa['racha_actual'],
      totalCompletados: mapa['total_completados'],
    );
  }
}
