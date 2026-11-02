import 'package:shared_preferences/shared_preferences.dart';

// ===================== CLAVES =====================
// Ahora los usuarios, hábitos y estadísticas están en la base de datos.
// En SharedPreferences solo quedan los ajustes y datos pequeños de la app.
class Claves {
  static const String usuarioSesion = 'usuario_sesion'; // int
  static const String objetivoDiario = 'objetivo_diario'; // int
  static const String contadorAperturas = 'contador_aperturas'; // int
  static const String ultimaApertura = 'ultima_apertura'; // String
  static const String temaOscuro = 'tema_oscuro'; // bool
  static const String ocultarCompletados = 'ocultar_completados'; // bool
  static const String tamanoLetra = 'tamano_letra'; // double
}

// Única clase que usa SharedPreferences.
class PreferenciasService {
  // ---------- Sesión ----------

  // Guardamos el id del usuario que ha iniciado sesión para que, al volver
  // a abrir la app, no tenga que escribir otra vez su contraseña.
  Future<void> guardarSesion(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(Claves.usuarioSesion, usuarioId);
  }

  // Devuelve null si nadie ha iniciado sesión.
  Future<int?> leerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Claves.usuarioSesion);
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Claves.usuarioSesion);
  }

  // ---------- Objetivo diario ----------

  Future<int> leerObjetivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Claves.objetivoDiario) ?? 3;
  }

  Future<void> guardarObjetivo(int objetivo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(Claves.objetivoDiario, objetivo);
  }

  // ---------- Aperturas ----------

  // Se llama una vez cada vez que se abre la app (desde main).
  Future<void> registrarApertura() async {
    final prefs = await SharedPreferences.getInstance();
    final aperturas = prefs.getInt(Claves.contadorAperturas) ?? 0;
    await prefs.setInt(Claves.contadorAperturas, aperturas + 1);
    await prefs.setString(
      Claves.ultimaApertura,
      DateTime.now().toIso8601String(),
    );
  }

  Future<int> leerAperturas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Claves.contadorAperturas) ?? 0;
  }

  Future<String?> leerUltimaApertura() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Claves.ultimaApertura);
  }

  // ---------- Ajustes ----------

  Future<bool> leerTemaOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Claves.temaOscuro) ?? false;
  }

  Future<void> guardarTemaOscuro(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Claves.temaOscuro, valor);
  }

  Future<double> leerTamanoLetra() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(Claves.tamanoLetra) ?? 1.0;
  }

  Future<void> guardarTamanoLetra(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(Claves.tamanoLetra, valor);
  }

  Future<bool> leerOcultarCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Claves.ocultarCompletados) ?? false;
  }

  Future<void> guardarOcultarCompletados(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Claves.ocultarCompletados, valor);
  }

  // ---------- Borrar datos ----------

  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
