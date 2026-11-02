# HabitosApp

App en Flutter para apuntar los hábitos del día (beber agua, caminar, sacar al perro...). Proyecto de DAM2 para Acceso a Datos y Diseño de Interfaces.

## Para probarla

```
flutter pub get
dart run sqflite_common_ffi_web:setup
flutter run
```

El segundo comando solo hace falta para ejecutarla en el navegador (copia en `web/` los archivos que necesita SQLite).

Al abrirla por primera vez ya existe un administrador:

- Usuario: `admin`
- Contraseña: `admin`

Los demás usuarios se crean desde la pantalla de registro.

-----

## Persistencia de datos (I)

La primera versión guardaba todo con `shared_preferences`: el nombre, el objetivo diario, los hábitos (como JSON), el tema, el tamaño de letra y el número de aperturas. Ahora `shared_preferences` solo se usa para los ajustes y la sesión (ver más abajo).

-----

## Diseño de Interfaces: pantallas y navegación

Primera versión de la interfaz: bienvenida, pantalla principal con la ficha del hábito y el editor con tres colores (azul, verde y naranja). Guardar actualiza la ficha y Cancelar vuelve sin cambiar nada.

-----

## Persistencia de datos (II): base de datos

Los usuarios, los hábitos y las estadísticas ahora están en una base de datos SQLite con `sqflite` (en el navegador se usa `sqflite_common_ffi_web`). Hay tres tablas:

- usuarios: usuario, nombre, apellidos, email, contraseña, fecha de creación (se pone sola al registrarse) y rol (`usuario` o `administrador`).
- habitos: id, usuario al que pertenece, nombre, color y fechas en que se ha completado (guardadas como JSON).
- estadisticas: racha actual y total de días completados de cada hábito. Se actualizan solas cada vez que se marca o se edita un hábito.

Cada tabla tiene su servicio con el CRUD completo (`UsuariosService`, `HabitosService`, `EstadisticasService`). La base de datos se abre y se crea en `BaseDatos`.

En `shared_preferences` se quedan el usuario que tiene la sesión iniciada, el objetivo diario, el tema, el tamaño de letra, ocultar completados y las aperturas.

Roles:

- Usuario: solo ve sus hábitos y sus estadísticas. Puede crear, editar, marcar y borrar sus hábitos.
- Administrador: entra a la pantalla de Administración. Puede crear, editar y borrar usuarios, gestionar los hábitos de cualquier usuario, ver las estadísticas de todos y editarlas o borrarlas, y borrar todos los datos desde Ajustes.

-----

## Diseño de Interfaces: interfaces y componentes

La carpeta `lib` está organizada así:

```
lib/
  main.dart
  pantallas/   inicio, login, registro, hábitos, editar hábito, estadísticas,
               ajustes, administración y editar usuario
  widgets/     componentes reutilizables
  modelos/     Usuario, Habito y Estadistica
  servicios/   base de datos, CRUD de cada tabla y shared_preferences
```

Componentes reutilizables (todos son `StatelessWidget` y reciben por constructor los datos y las acciones):

- CampoTextoApp: campo de texto con etiqueta, controlador y opción de ocultar el texto. Se usa en el login, el registro, el editor de hábitos, el formulario de usuarios y al editar estadísticas.
- BotonPrincipal: botón de las acciones principales (Entrar, Registrarse, Guardar). Recibe el texto y la acción.
- TarjetaHabito: tarjeta de cada hábito con nombre, color, si está completado hoy e icono. Recibe las acciones de completar, editar y eliminar.
- DatoEstadistica: muestra un dato con icono, valor y etiqueta. Se usa para la racha, los días completados, las aperturas y la última apertura.

Las pantallas mantienen el estado y llaman a los servicios. Los componentes solo muestran lo que reciben y ejecutan los callbacks. Por ejemplo, al pulsar Eliminar en una tarjeta, la pantalla pide confirmación y, si se acepta, le pide al servicio que borre el hábito.
