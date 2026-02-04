# Installation & Setup

## 1. Installer Flutter

### macOS
```bash
# Avec Homebrew
brew install flutter

# Ou téléchargement direct
# https://docs.flutter.dev/get-started/install/macos
```

### Linux
```bash
# Snap (Ubuntu/Debian)
sudo snap install flutter --classic

# Ou téléchargement manuel
# https://docs.flutter.dev/get-started/install/linux
```

### Windows
```bash
# Télécharge et extraie le SDK
# https://docs.flutter.dev/get-started/install/windows
# Ajoute Flutter au PATH
```

### Vérification
```bash
flutter doctor
```
Installe ce qui manque (Android Studio, Xcode si macOS, etc.)

---

## 2. Créer le projet

```bash
# Crée le projet Flutter
flutter create fitness_app
cd fitness_app

# Teste que ça marche
flutter run
```

---

## 3. Setup Firebase

### A. Console Firebase
1. Va sur https://console.firebase.google.com
2. Crée un projet "FitnessApp"
3. Active Authentication (Email/Password + Google)
4. Active Firestore Database (mode test pour commencer)
5. Active Storage

### B. FlutterFire CLI
```bash
# Installe FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase pour ton app
flutterfire configure
```
Sélectionne ton projet, les plateformes (iOS, Android, Web optionnel).

---

## 4. Dépendances initiales

Ajoute dans `pubspec.yaml` :

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.5.6
  
  # State management
  provider: ^6.1.1
  
  # UI
  google_fonts: ^6.1.0
  
  # Utils
  intl: ^0.18.1  # dates/formats
  uuid: ^4.2.2   # IDs uniques
```

Puis :
```bash
flutter pub get
```

---

## 5. Structure de projet

Crée cette structure dans `lib/` :

```
lib/
├── main.dart
├── firebase_options.dart  (généré par flutterfire)
│
├── models/
│   ├── user_model.dart
│   ├── group_model.dart
│   ├── workout_program.dart
│   └── meal_plan.dart
│
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── storage_service.dart
│
├── providers/
│   ├── auth_provider.dart
│   └── user_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── groups/
│   │   ├── groups_list_screen.dart
│   │   ├── group_detail_screen.dart
│   │   └── create_group_screen.dart
│   ├── workouts/
│   │   ├── workouts_screen.dart
│   │   └── create_workout_screen.dart
│   ├── nutrition/
│   │   └── nutrition_screen.dart
│   └── profile/
│       └── profile_screen.dart
│
└── widgets/
    └── (composants réutilisables)
```

---

## 6. Configuration Firestore Rules (sécurité)

Dans Firebase Console → Firestore → Rules :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users : lecture publique, écriture proprio uniquement
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Groups : membres seulement
    match /groups/{groupId} {
      allow read: if request.auth.uid in resource.data.members;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
    
    // Workout programs : membres du groupe
    match /workoutPrograms/{programId} {
      allow read: if request.auth.uid in get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.members;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
    
    // User logs : proprio seulement
    match /userWorkoutLogs/{logId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    
    match /userMealLogs/{logId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    
    // Meal plans : comme workout programs
    match /mealPlans/{mealPlanId} {
      allow read: if request.auth.uid in get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.members;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

---

## 7. Lancer l'app

```bash
# Simulateur iOS (macOS seulement)
flutter run -d iphone

# Émulateur Android
flutter run -d emulator

# Chrome (web, pour dev rapide)
flutter run -d chrome
```

---

## 🎯 Checklist de démarrage

- [ ] Flutter installé (`flutter doctor` OK)
- [ ] Projet créé
- [ ] Firebase projet configuré
- [ ] FlutterFire configuré (`flutterfire configure`)
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Structure de dossiers créée
- [ ] App lance sans erreur

**Prêt !** Passe à l'implémentation des premiers écrans (auth).
