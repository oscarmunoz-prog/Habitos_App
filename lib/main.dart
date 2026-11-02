import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'pantallas/inicio_page.dart';
import 'servicios/preferencias_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite funciona directamente en Android e iOS. En el navegador
  // (kIsWeb) necesita esta versión especial para web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // PERSISTENCIA: main se ejecuta una vez cada vez que se abre la app.
  await PreferenciasService().registrarApertura();

  runApp(const MyApp());
}

// MyApp es StatefulWidget porque el tema y el tamaño de letra pueden
// cambiar desde Ajustes y afectan a todas las pantallas.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _temaOscuro = false;
  double _tamanoLetra = 1.0;

  // Las pantallas reciben esta función y la llaman cuando cambian los ajustes.
  void _cambiarAjustes(bool temaOscuro, double tamanoLetra) {
    setState(() {
      _temaOscuro = temaOscuro;
      _tamanoLetra = tamanoLetra;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitosApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: _temaOscuro ? Brightness.dark : Brightness.light,
      ),
      // builder envuelve todas las pantallas: así el tamaño de letra
      // se aplica a los textos de toda la app.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_tamanoLetra),
          ),
          child: child!,
        );
      },
      home: InicioPage(onCambiarAjustes: _cambiarAjustes),
    );
  }
}
