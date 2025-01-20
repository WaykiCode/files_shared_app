# files_shared_app
Aplicacion realizada en flutter v3.24.5 para el proyecto de comparticion de archivos

## Limpia el Caché de Build
flutter clean
flutter pub get
flutter run

## Usa el Paquete flutter_launcher_icons
### Agregar Dependencia
En el archivo pubspec.yaml, agrega lo siguiente:

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon.png" # Ruta a tu archivo PNG

#### Ejecuta:

flutter pub get

### Después de configurar el ícono en pubspec.yaml, genera los íconos con:

flutter pub run flutter_launcher_icons:main

Esto actualizará automáticamente los íconos en las carpetas android e ios.