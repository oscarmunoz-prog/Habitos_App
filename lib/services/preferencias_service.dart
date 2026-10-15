import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habito.dart';

// ===================== CLAVES =====================
// Los nombres con los que guardamos cada dato. Al tenerlos en constantes
// no hay cadenas sueltas repartidas por el código.
class Claves {
  static const String nombreUsuario = 'nombre_usuario'; // String
  static const String ultimaApertura = 'ultima_apertura'; // String
  static const String objetivoDiario = 'objetivo_diario'; // int
  static const String contadorAperturas = 'contador_aperturas'; // int
  static const String temaOscuro = 'tema_oscuro'; // bool
  static const String ocultarCompletados = 'ocultar_completados'; // bool
  static const String tamanoLetra = 'tamano_letra'; // double
  static const String habitos = 'habitos'; // List<String>
}

// ===================== SERVICIO =====================
// Única clase que usa SharedPreferences. Las pantallas llaman a estos
// métodos y nunca acceden a SharedPreferences directamente.
//
// Todos los métodos son async porque leer y guardar en el dispositivo no
// es instantáneo. Quien los llame debe esperar el resultado con await.
//
// En la primera ejecución las claves no existen y los métodos getX()
// devuelven null. Con ?? indicamos el valor que se usa en ese caso.
class PreferenciasService {
  // ---------- Usuario ----------

  // Devuelve null si es la primera vez (todavía no hay nombre guardado).
  Future<String?> leerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Claves.nombreUsuario);
  }

  Future<int> leerObjetivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Claves.objetivoDiario) ?? 1;
  }

  Future<void> guardarUsuario(String nombre, int objetivo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Claves.nombreUsuario, nombre);
    await prefs.setInt(Claves.objetivoDiario, objetivo);
  }

  // ---------- Hábitos ----------

  // Cada hábito está guardado como un texto JSON dentro de una List<String>.
  // texto --jsonDecode--> Map --Habito.fromJson--> Habito
  Future<List<Habito>> leerHabitos() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(Claves.habitos) ?? [];
    return lista.map((texto) => Habito.fromJson(jsonDecode(texto))).toList();
  }

  // Habito --toJson--> Map --jsonEncode--> texto
  Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = habitos.map((habito) => jsonEncode(habito.toJson())).toList();
    await prefs.setStringList(Claves.habitos, lista);
  }

  // ---------- Aperturas ----------

  // Se llama una vez cada vez que se abre la app (desde main).
  Future<void> registrarApertura() async {
    final prefs = await SharedPreferences.getInstance();
    final aperturas = prefs.getInt(Claves.contadorAperturas) ?? 0;
    await prefs.setInt(Claves.contadorAperturas, aperturas + 1);
    // DateTime no se puede guardar directamente, lo guardamos como texto.
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

  // clear elimina todas las claves. La app queda como recién instalada.
  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}