import '../modelos/habito.dart';
import 'base_datos.dart';
import 'estadisticas_service.dart';

// CRUD de la tabla 'habitos'. Cada vez que cambia un hábito, también se
// actualizan sus estadísticas.
class HabitosService {
  final _estadisticas = EstadisticasService();

  // ---------- Crear ----------
  // Devuelve el id que le ha asignado la base de datos.
  Future<int> insertar(Habito habito) async {
    final db = await BaseDatos.obtener();
    final datos = habito.toMap();
    datos.remove('id');
    final id = await db.insert(BaseDatos.tablaHabitos, datos);

    // Creamos sus estadísticas con el id que acaba de recibir.
    final guardado = Habito(
      id: id,
      usuarioId: habito.usuarioId,
      nombre: habito.nombre,
      color: habito.color,
      fechasCompletado: habito.fechasCompletado,
    );
    await _estadisticas.guardarParaHabito(guardado);
    return id;
  }

  // ---------- Leer ----------
  // Solo los hábitos de un usuario: lo que ve el rol usuario.
  Future<List<Habito>> obtenerPorUsuario(int usuarioId) async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(
      BaseDatos.tablaHabitos,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return filas.map((fila) => Habito.fromMap(fila)).toList();
  }

  // Todos los hábitos de todos los usuarios: lo que ve el administrador.
  Future<List<Habito>> obtenerTodos() async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(BaseDatos.tablaHabitos);
    return filas.map((fila) => Habito.fromMap(fila)).toList();
  }

  // ---------- Actualizar ----------
  Future<void> actualizar(Habito habito) async {
    final db = await BaseDatos.obtener();
    await db.update(
      BaseDatos.tablaHabitos,
      habito.toMap(),
      where: 'id = ?',
      whereArgs: [habito.id],
    );
    await _estadisticas.guardarParaHabito(habito);
  }

  // ---------- Eliminar ----------
  // Primero borramos sus estadísticas y después el hábito.
  Future<void> eliminar(int id) async {
    final db = await BaseDatos.obtener();
    await _estadisticas.eliminarPorHabito(id);
    await db.delete(
      BaseDatos.tablaHabitos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Borra todos los hábitos de un usuario (al eliminar ese usuario).
  Future<void> eliminarPorUsuario(int usuarioId) async {
    final habitos = await obtenerPorUsuario(usuarioId);
    for (final habito in habitos) {
      await eliminar(habito.id!);
    }
  }
}
