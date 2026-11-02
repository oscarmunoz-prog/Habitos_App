import '../modelos/estadistica.dart';
import '../modelos/habito.dart';
import 'base_datos.dart';

// CRUD de la tabla 'estadisticas'.
class EstadisticasService {
  // ---------- Crear ----------
  Future<int> insertar(Estadistica estadistica) async {
    final db = await BaseDatos.obtener();
    final datos = estadistica.toMap();
    datos.remove('id');
    return db.insert(BaseDatos.tablaEstadisticas, datos);
  }

  // ---------- Leer ----------
  Future<List<Estadistica>> obtenerTodas() async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(BaseDatos.tablaEstadisticas);
    return filas.map((fila) => Estadistica.fromMap(fila)).toList();
  }

  // Devuelve null si el hábito todavía no tiene estadísticas.
  Future<Estadistica?> obtenerPorHabito(int habitoId) async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(
      BaseDatos.tablaEstadisticas,
      where: 'habito_id = ?',
      whereArgs: [habitoId],
    );
    if (filas.isEmpty) return null;
    return Estadistica.fromMap(filas.first);
  }

  // ---------- Actualizar ----------
  Future<void> actualizar(Estadistica estadistica) async {
    final db = await BaseDatos.obtener();
    await db.update(
      BaseDatos.tablaEstadisticas,
      estadistica.toMap(),
      where: 'id = ?',
      whereArgs: [estadistica.id],
    );
  }

  // ---------- Eliminar ----------
  Future<void> eliminar(int id) async {
    final db = await BaseDatos.obtener();
    await db.delete(
      BaseDatos.tablaEstadisticas,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> eliminarPorHabito(int habitoId) async {
    final db = await BaseDatos.obtener();
    await db.delete(
      BaseDatos.tablaEstadisticas,
      where: 'habito_id = ?',
      whereArgs: [habitoId],
    );
  }

  // Calcula la racha y el total del hábito y los guarda: si ya tenía
  // estadísticas las actualiza y, si no, las crea.
  Future<void> guardarParaHabito(Habito habito) async {
    final anterior = await obtenerPorHabito(habito.id!);
    final nueva = Estadistica(
      id: anterior?.id,
      habitoId: habito.id!,
      rachaActual: habito.rachaActual(),
      totalCompletados: habito.totalDias(),
    );

    if (anterior == null) {
      await insertar(nueva);
    } else {
      await actualizar(nueva);
    }
  }
}
