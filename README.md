# MySpool

Aplicacion Flutter para gestionar una biblioteca local de filamentos 3D.

## Funciones

- Biblioteca de bobinas con stock, peso, color y caracteristicas de impresion.
- Catalogo de fabricantes y sugerencias de colores.
- Lectura de etiquetas NFC compatibles de Anycubic.
- Paleta visual, consumo, papelera y recordatorios de stock bajo.
- Historial manual de precios y enlaces de busqueda en Google.
- Persistencia local mediante SQLite.

## Desarrollo

Requisitos:

- Flutter 3.35 o posterior.
- Dart 3.9 o posterior.
- Android Studio o un dispositivo Android con NFC para probar esa funcion.

Comandos habituales:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Para generar un APK:

```powershell
flutter build apk --release
```

El APK de las versiones publicadas se distribuye como asset de GitHub Release.
