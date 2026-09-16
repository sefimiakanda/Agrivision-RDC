# Agrivision RDC

Application Flutter d'aide à la gestion des cultures et au conseil agricole en République Démocratique du Congo.

## Fonctionnalités disponibles

- Carnet agricole hors connexion avec SQLite : parcelles et activités.
- Météo agricole : conditions actuelles et prévisions OpenWeatherMap.
- Assistant agricole Gemini : à venir.

## Lancer l'application

Installer les dépendances puis lancer Flutter :

```powershell
flutter pub get
flutter run --dart-define=OPENWEATHER_API_KEY=votre_cle_openweathermap
```

La clé météo est injectée au lancement et n'est pas stockée dans le dépôt. Sans clé, l'écran météo affiche une erreur de configuration explicite.

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
