# Agrivision RDC

Application Flutter d'aide à la gestion des cultures et au conseil agricole en République Démocratique du Congo.

## Fonctionnalités disponibles

- Carnet agricole hors connexion avec SQLite : parcelles et activités.
- Météo agricole : conditions actuelles et prévisions OpenWeatherMap.
- Assistant agricole Gemini : questions et conseils en français.
- Profil d’exploitation local : nom, ville, culture principale et superficie.

## Lancer l'application

Installer les dépendances puis lancer Flutter :

```powershell
flutter pub get
flutter run --dart-define=OPENWEATHER_API_KEY=votre_cle_openweathermap --dart-define=GEMINI_API_KEY=votre_cle_gemini
```

Les clés météo et Gemini sont injectées au lancement et ne sont pas stockées dans le dépôt. Sans clé correspondante, l’écran concerné affiche une erreur de configuration explicite.

## Vérifications

```powershell
flutter analyze
flutter test
```

## Structure principale

```text
lib/
  controllers/   # Provider par domaine
  database/      # Repository et SQLite
  models/        # Modèles métier
  services/      # APIs distantes
  views/         # Écrans Flutter
```
