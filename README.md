# HabitosApp

Esto es una app hecha en Flutter que sirve para apuntar los hábitos del día como: beber agua, caminar, sacar al perro, etc.

Todo se guarda en local con "shared_preferences", sin base de datos.

## Qué hace?

- La primera vez pide tu nombre y cuántos hábitos quieres hacer al día. Las siguientes veces entra directamente.
- En la pantalla principal te saluda, te dice cuántos llevas hoy (por ejemplo "2 de 5 hábitos") y puedes marcarlos.
- Puedes crear, editar y borrar hábitos. Cada uno tiene nombre, color y los días en que lo has hecho.
- En estadísticas sale la racha y el total de días de cada hábito, cuántas veces has abierto la app y cuándo fue la última.
- En ajustes puedes cambiar entre tema claro y oscuro, cambiar el tamaño de letra y ocultar los hábitos que ya has hecho hoy.
- También hay un botón para borrar todos los datos y dejar la app como recién instalada.

## Cómo está organizado?

Está organizado de la siguiente manera:
lib/
  main.dart
  models/     -> clase Habito 
  services/   -> PreferenciasService y las claves
  screens/    -> las pantallas
  widgets/    -> la fila de cada hábito


Solo "PreferenciasService" toca "SharedPreferences"; las pantallas siempre pasan por él y as claves están en la clase "Claves".

Se usan los cinco tipos que permite "shared_preferences" que son los siguientes:

- "String": el nombre y la fecha de la última apertura
- "int": el objetivo diario y el número de aperturas
- "bool": el tema oscuro y lo de ocultar completados
- "double": el tamaño de letra
- "List<String>": los hábitos, cada uno guardado como JSON con "jsonEncode" y leído con "jsonDecode"

## Actualización: Desenvolupament de Interficies

Para la actividad de Desenvolupament de Interficies hemos usado el mismo proyecto y hemos retocado las pantallas para que cumplan lo que se pedía, sin perder nada de lo de Acceso a Datos.

Cambios que hemos hecho:

- Bienvenida: ahora sale el nombre de la app arriba y el botón pone comenzar, el nombre y el objetivo se pasan a la pantalla principal por el constructor y el campo del objetivo solo deja escribir números, porque antes se podía poner texto y daba error.
- Pantalla Principal: Recibe el nombre y el objetivo desde la pantalla anterior en vez de leerlos otra vez, y muestra el objetivo diario además del progreso.
- Ficha del hábito: Cada hábito se ve como una ficha con un icono, el nombre en negrita, el nombre del color, si está hecho hoy o pendiente, y los botones "Editar hábito" y "Borrar".
- Editar hábito: ahora hay tres colores que son azul, verde y naranja en una fila de botones.
- Guardar y Cancelar: "Guardar" vuelve a la principal y actualiza la ficha en cambio "Cancelar" o la flecha de atrás vuelven sin cambiar nada.


Todas las pantallas tienen su Scaffold con AppBar y los campos de texto llevan labelText, OutlineInputBorder y SingleChildScrollView.

## Que archivos se han cambiado?

Los archivos que se han cambiado/actualizado son los siguientes:

1. habito.dart
2. inicio_page.dart 
3. bienvenida_page.dart
4. principal_page.dart
5. editar_habito_page.dart
6. habito_tile.dart