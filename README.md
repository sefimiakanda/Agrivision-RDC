# Agrivision RDC

Application Flutter d'aide à la gestion des cultures et au conseil agricole en République Démocratique du Congo.

## Fonctionnalités disponibles

- Carnet agricole hors connexion avec SQLite : parcelles et activités.
- Météo agricole : conditions actuelles et prévisions OpenWeatherMap.
- Assistant agricole Gemini : questions et conseils en français, avec fallback de modèle.
- Profil agricole local : nom de l’agriculteur et ville.
- Accueil personnalisé avec l’icône de l’application et des badges météo.
- Navigation mobile inférieure : Accueil, Carnet, Météo et Assistant.

## Prérequis

- Flutter stable et Dart compatibles avec le SDK du projet.
- Android Studio avec un JDK embarqué pour compiler Android.
- Un appareil Android ou un émulateur visible avec `flutter devices`.

Sur Windows, si Java n’est pas disponible dans le terminal :

```powershell
$env:JAVA_HOME = 'M:\Android Studio install\jbr'
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```

## Lancer l’application

Installer les dépendances puis lancer Flutter :

```powershell
flutter pub get
flutter run --dart-define=OPENWEATHER_API_KEY=votre_cle_openweathermap --dart-define=GEMINI_API_KEY=votre_cle_gemini
```

Les clés météo et Gemini sont injectées au lancement et ne sont pas stockées dans le dépôt. Une clé Gemini doit être active pour l’API Generative Language et autorisée à utiliser un modèle `generateContent`. L’application essaie `gemini-2.5-flash`, puis `gemini-2.5-flash-lite` et enfin `gemini-2.0-flash` si un modèle n’est pas disponible.

Pour vérifier l’appareil et éviter les caches Android corrompus :

```powershell
flutter devices
flutter clean
flutter pub get
flutter run --dart-define=OPENWEATHER_API_KEY=votre_cle_openweathermap --dart-define=GEMINI_API_KEY=votre_cle_gemini
```

Ne placez jamais une clé réelle dans `README.md`, le code source ou un commit Git. Si une clé a été publiée, révoquez-la et créez-en une nouvelle.

## Tests et vérifications

Les tests sont organisés en trois niveaux :

- Tests unitaires Gemini : parsing de réponse, refus de clé et fallback de modèle.
- Tests unitaires météo : parsing des conditions/prévisions et ville inconnue.
- Tests widget : navigation inférieure, accueil personnalisé, profil et carnet.

```powershell
flutter analyze
flutter test
flutter test test/gemini_service_test.dart
flutter test test/weather_service_test.dart
flutter test test/widget_test.dart
```

La commande `flutter build apk --debug` valide aussi la compilation Android, mais ne remplace pas un lancement sur appareil réel.

## Structure principale

```text
lib/
  controllers/   # Provider par domaine
  database/      # Repository et SQLite
  models/        # Modèles métier
  services/      # APIs distantes
  views/         # Écrans Flutter
```
