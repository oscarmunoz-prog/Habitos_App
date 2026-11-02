import '../modelos/usuario.dart';
import 'base_datos.dart';
import 'habitos_service.dart';

// CRUD de la tabla 'usuarios', más el inicio de sesión.
class UsuariosService {
  final _habitos = HabitosService();

  // ---------- Crear ----------
  Future<int> insertar(Usuario usuario) async {
    final db = await BaseDatos.obtener();
    final datos = usuario.toMap();
    datos.remove('id');
    return db.insert(BaseDatos.tablaUsuarios, datos);
  }

  // ---------- Leer ----------
  Future<List<Usuario>> obtenerTodos() async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(BaseDatos.tablaUsuarios);
    return filas.map((fila) => Usuario.fromMap(fila)).toList();
  }

  Future<Usuario?> obtenerPorId(int id) async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(
      BaseDatos.tablaUsuarios,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (filas.isEmpty) return null;
    return Usuario.fromMap(filas.first);
  }

  // Sirve para comprobar si un nombre de usuario ya está ocupado.
  Future<Usuario?> buscarPorNombreUsuario(String nombreUsuario) async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(
      BaseDatos.tablaUsuarios,
      where: 'usuario = ?',
      whereArgs: [nombreUsuario],
    );
    if (filas.isEmpty) return null;
    return Usuario.fromMap(filas.first);
  }

  // Devuelve el usuario si el nombre y la contraseña coinciden, o null.
  Future<Usuario?> iniciarSesion(String nombreUsuario, String contrasena) async {
    final db = await BaseDatos.obtener();
    final filas = await db.query(
      BaseDatos.tablaUsuarios,
      where: 'usuario = ? AND contrasena = ?',
      whereArgs: [nombreUsuario, contrasena],
    );
    if (filas.isEmpty) return null;
    return Usuario.fromMap(filas.first);
  }

  // ---------- Actualizar ----------
  Future<void> actualizar(Usuario usuario) async {
    final db = await BaseDatos.obtener();
    await db.update(
      BaseDatos.tablaUsuarios,
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // ---------- Eliminar ----------
  // Al borrar un usuario también se borran sus hábitos y estadísticas.
  Future<void> eliminar(int id) async {
    final db = await BaseDatos.obtener();
    await _habitos.eliminarPorUsuario(id);
    await db.delete(
      BaseDatos.tablaUsuarios,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
