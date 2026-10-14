import 'package:flutter/material.dart';

import 'screens/inicio_page.dart';
import 'services/preferencias_service.dart';

// main es async porque esperamos a guardar la apertura antes de arrancar.
Future<void> main() async {
  // Necesario para usar shared_preferences antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // PERSISTENCIA: main se ejecuta una vez cada vez que se abre la app
  // (en el navegador, cada vez que se refresca la página).
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
      theme: _temaOscuro ? ThemeData.dark() : ThemeData.light(),
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
