import 'package:sqflite/sqflite.dart';

import '../modelos/usuario.dart';

// Abre la base de datos local y crea las tablas la primera vez.
// Los demás servicios piden la base de datos a esta clase.
class BaseDatos {
  static const String nombreArchivo = 'habitos.db';

  // Nombres de las tablas, en constantes para no repetir texto suelto.
  static const String tablaUsuarios = 'usuarios';
  static const String tablaHabitos = 'habitos';
  static const String tablaEstadisticas = 'estadisticas';

  // Guardamos la base de datos abierta para no abrirla cada vez.
  static Database? _baseDatos;

  static Future<Database> obtener() async {
    // Si todavía no está abierta, la abrimos. Con una ruta sin carpeta,
    // sqflite la guarda en la carpeta de bases de datos de la app.
    _baseDatos ??= await openDatabase(
      nombreArchivo,
      version: 1,
      onCreate: _crearTablas,
    );
    return _baseDatos!;
  }

  // onCreate solo se ejecuta la primera vez, cuando el archivo no existe.
  static Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaUsuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        email TEXT NOT NULL,
        contrasena TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        rol TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaHabitos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        color INTEGER NOT NULL,
        fechas_completado TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES $tablaUsuarios (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaEstadisticas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habito_id INTEGER NOT NULL UNIQUE,
        racha_actual INTEGER NOT NULL,
        total_completados INTEGER NOT NULL,
        FOREIGN KEY (habito_id) REFERENCES $tablaHabitos (id)
      )
    ''');

    // Creamos un administrador para poder entrar la primera vez.
    final admin = Usuario(
      usuario: 'admin',
      nombre: 'Administrador',
      apellidos: 'HabitosApp',
      email: 'admin@habitosapp.com',
      contrasena: 'admin',
      fechaCreacion: DateTime.now().toIso8601String(),
      rol: Usuario.rolAdmin,
    );
    final datosAdmin = admin.toMap();
    // Quitamos el id (null) para que lo asigne la base de datos.
    datosAdmin.remove('id');
    await db.insert(tablaUsuarios, datosAdmin);
  }

  // Borra el archivo de la base de datos. La próxima vez que se abra,
  // se volverán a crear las tablas vacías (con el administrador).
  static Future<void> borrarTodo() async {
    await _baseDatos?.close();
    _baseDatos = null;
    await deleteDatabase(nombreArchivo);
  }
}
