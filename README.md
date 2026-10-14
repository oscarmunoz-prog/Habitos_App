# habitosapp

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