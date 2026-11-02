// Datos de un usuario de la aplicación.
class Usuario {
  // Los dos roles posibles.
  static const String rolAdmin = 'administrador';
  static const String rolUsuario = 'usuario';

  // id es null hasta que el usuario se guarda en la base de datos,
  // que es quien le asigna el número.
  final int? id;
  final String usuario;
  final String nombre;
  final String apellidos;
  final String email;
  final String contrasena;
  // Fecha en texto ISO 8601. Se asigna automáticamente al registrarse.
  final String fechaCreacion;
  final String rol;

  const Usuario({
    this.id,
    required this.usuario,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.contrasena,
    required this.fechaCreacion,
    required this.rol,
  });

  bool esAdmin() {
    return rol == rolAdmin;
  }

  // PERSISTENCIA: convierte el objeto en un Map para guardarlo en la tabla.
  // Las claves del Map son los nombres de las columnas.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario': usuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'contrasena': contrasena,
      'fecha_creacion': fechaCreacion,
      'rol': rol,
    };
  }

  // PERSISTENCIA: crea un Usuario a partir de una fila de la tabla.
  factory Usuario.fromMap(Map<String, dynamic> mapa) {
    return Usuario(
      id: mapa['id'],
      usuario: mapa['usuario'],
      nombre: mapa['nombre'],
      apellidos: mapa['apellidos'],
      email: mapa['email'],
      contrasena: mapa['contrasena'],
      fechaCreacion: mapa['fecha_creacion'],
      rol: mapa['rol'],
    );
  }
}
