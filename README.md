# Movie Archive

Aplicación móvil desarrollada con Flutter para consultar y administrar un
catálogo de películas. Incluye registro e inicio de sesión con
Firebase Authentication, almacenamiento de usuarios y películas en Cloud
Firestore, búsqueda en el catálogo y operaciones para crear, editar y
eliminar películas.

## Funcionalidades

- Registro de usuarios con nombre, correo, contraseña y fecha de nacimiento.
- Inicio y cierre de sesión con Firebase Authentication.
- Catálogo de películas ordenado alfabéticamente.
- Búsqueda por texto.
- Vista detallada de cada película.
- Archivo para administrar las películas, con paginación.
- Alta, edición y eliminación de películas.
- Interfaz en español de México.

## Probar sin compilar

Si solo quieres probar la aplicación, instala el APK desde la sección
**Releases** del repositorio en un teléfono Android (permite instalar apps de
orígenes desconocidos) y crea una cuenta desde *Regístrate*. No necesitas
configurar nada más.

## Requisitos

Para ejecutar el código, instala las siguientes herramientas:

- [Flutter](https://docs.flutter.dev/get-started/install) con Dart SDK
  compatible con `^3.13.5`.
- [Android Studio](https://developer.android.com/studio) o las herramientas
  de Android SDK y un emulador/dispositivo físico.
- Una cuenta de Google para crear tu propio proyecto de Firebase.
- Git, si vas a descargar el proyecto desde un repositorio.

Comprueba la instalación con:

```bash
flutter doctor
```

## Descargar el proyecto

Clona el repositorio, entra en la carpeta de la aplicación e instala las
dependencias:

```bash
git clone <URL_DEL_REPOSITORIO>
cd movie_archive
flutter pub get
```

Si descargaste un archivo ZIP, extráelo y ejecuta los comandos desde la
carpeta que contiene `pubspec.yaml`.

## Configuración de Firebase

Por seguridad, el repositorio no incluye los archivos de configuración de
Firebase (`lib/firebase_options.dart` y `android/app/google-services.json`).
Sin ellos la aplicación no compila, así que debes generarlos con tu propio
proyecto:

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
2. Instala [Firebase CLI](https://firebase.google.com/docs/cli) e inicia
   sesión con `firebase login`.
3. Desde la raíz del proyecto, ejecuta:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Elige tu proyecto y la plataforma Android. Esto registra la aplicación y
   crea `lib/firebase_options.dart` y `android/app/google-services.json`.
4. En Firebase Authentication, habilita el proveedor **Correo electrónico y
   contraseña**.
5. Crea una base de datos de Cloud Firestore en modo producción.
6. Pega estas reglas en Firestore → Reglas y publícalas. Solo permiten el
   acceso a usuarios con sesión iniciada.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }

    match /users/{uid} {
      allow read, create, update: if signedIn() && request.auth.uid == uid;
      allow delete: if false;
    }
    match /movies/{movieId} {
      allow read, write: if signedIn();
    }
  }
}
```

El proyecto utiliza las colecciones `users` y `movies`. La aplicación envía
las solicitudes de Firestore usando el token de la sesión activa.


## Ejecutar la aplicación

Lista los dispositivos disponibles:

```bash
flutter devices
```

Inicia la aplicación en un emulador o dispositivo conectado:

```bash
flutter run
```

También puedes seleccionar un dispositivo concreto:

```bash
flutter run -d <ID_DEL_DISPOSITIVO>
```

La configuración actual incluye Android. La compatibilidad con iOS, web o
desktop requiere agregar la plataforma correspondiente y su configuración de
Firebase.

## Primeros pasos en la app

La base de datos empieza vacía. Crea una cuenta, entra a **Archivo** desde el
menú ☰, toca **Añadir** y pega la URL pública de un póster vertical (la app
guarda solo la URL, no la imagen). Después verás la película en el
**Catálogo**, donde también puedes buscarla con la lupa.

## Compilar una versión instalable

Para generar un APK de producción:

```bash
flutter build apk --release
```

El archivo generado se encuentra normalmente en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Para generar un Android App Bundle:

```bash
flutter build appbundle --release
```

## Desarrollo y validación

Antes de enviar cambios, ejecuta el analizador y las pruebas:

```bash
flutter analyze
flutter test
```

Para aplicar el formateo de Dart:

```bash
dart format .
```

Durante el desarrollo puedes usar recarga en caliente presionando `r` en la
terminal donde se ejecuta `flutter run`. Si agregas archivos nuevos, usa
reinicio completo con `R`.

## Estructura del proyecto

```text
lib/
├── core/                 # Router, tema, utilidades y widgets compartidos
├── data/
│   ├── models/           # Modelos de datos, como Movie
│   ├── repositories/     # Contratos e implementación de acceso a películas
│   └── services/         # Firebase Auth y cliente REST de Firestore
├── features/
│   ├── auth/             # Login y registro
│   ├── catalog/          # Catálogo y tarjetas de películas
│   ├── archive/          # Archivo y formulario de películas
│   └── detail/           # Detalle de una película
├── firebase_options.dart # Generado con flutterfire configure (no se sube)
└── main.dart             # Punto de entrada de la aplicación
```

Las rutas principales son:

- `/login`: inicio de sesión.
- `/register`: registro.
- `/catalog`: catálogo.
- `/archive`: archivo.
- `/movie/new`: crear una película.
- `/movie/:id`: detalle de una película.
- `/movie/:id/edit`: editar una película.

## Flujo de datos

Las pantallas dependen de la abstracción `MovieRepository`, no directamente
de Firestore. La implementación actual, `FirestoreMovieRepository`, usa
`FirestoreRest` para comunicarse con Cloud Firestore y `AuthService` para
obtener el token de Firebase Authentication. Esto permite sustituir el origen
de datos por otro repositorio, como `MockMovieRepository`, durante pruebas o
desarrollo sin conexión.