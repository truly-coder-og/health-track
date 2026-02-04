# 🚀 Quick Start Guide

## Ce qui est déjà fait

✅ **Architecture complète**
- Structure de projet organisée
- Modèles de données (User, Group, WorkoutProgram, WorkoutLog)
- Services (Auth, Database)
- Écran de login fonctionnel
- Configuration Firebase

✅ **Code prêt à l'emploi**
- Authentification email/password
- Gestion des groupes (créer, rejoindre via code)
- CRUD programmes d'entraînement
- Logs de sessions personnelles

---

## Démarrer maintenant (15 minutes)

### 1. Installer Flutter
```bash
# Vérifie si Flutter est déjà installé
flutter --version

# Si non installé, suis SETUP.md section 1
```

### 2. Créer le projet Flutter
```bash
# Crée le projet
flutter create fitness_app
cd fitness_app

# Copie les fichiers fournis dans le projet
# - Remplace lib/main.dart par le fichier fourni
# - Copie models/, services/, screens/ dans lib/
```

### 3. Ajouter les dépendances

Modifie `pubspec.yaml` (section dependencies) :

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.5.6
  provider: ^6.1.1
  google_fonts: ^6.1.0
  intl: ^0.18.1
  uuid: ^4.2.2
```

Puis :
```bash
flutter pub get
```

### 4. Configurer Firebase

**A. Console Firebase**
1. Va sur https://console.firebase.google.com
2. Clique "Ajouter un projet"
3. Nom : `fitness-app` (ou ton choix)
4. Active Google Analytics (optionnel)
5. Projet créé !

**B. Active les services**
- **Authentication** → Méthodes de connexion → Email/Mot de passe → Active
- **Firestore Database** → Créer une base de données → Mode **test** (pour commencer)
- **Storage** → Commencer → Mode **test**

**C. Connecte ton app**
```bash
# Installe FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```
Sélectionne ton projet `fitness-app`, puis les plateformes (iOS, Android).

Ça va générer `lib/firebase_options.dart` automatiquement.

### 5. Copie les Firestore Rules

Dans Firebase Console → Firestore → Rules, copie ceci :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /groups/{groupId} {
      allow read: if request.auth.uid in resource.data.members;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
    
    match /workoutPrograms/{programId} {
      allow read: if request.auth.uid in get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.members;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
    
    match /userWorkoutLogs/{logId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

**Publie les règles.**

### 6. Lance l'app !

```bash
# Liste les devices disponibles
flutter devices

# Lance sur iOS simulator (macOS)
flutter run -d iphone

# Lance sur Android emulator
flutter run -d emulator

# Lance sur Chrome (rapide pour dev)
flutter run -d chrome
```

---

## Test rapide

1. L'app lance → tu vois l'écran de login
2. Clique "Pas encore de compte" → *erreur : signup_screen n'existe pas encore*
3. **Normal !** Crée un compte directement dans Firebase Console :
   - Authentication → Users → Add user
   - Email : `test@test.com`
   - Password : `test1234`

4. Retourne dans l'app, connecte-toi avec ces identifiants
5. Tu vois "Connecté !" → **ça marche !**

---

## Prochaines étapes (ordre de dev)

### Semaine 1 : Compléter l'auth
- [ ] Créer `screens/auth/signup_screen.dart` (copie login_screen.dart, adapte)
- [ ] Ajouter la route dans `main.dart`

### Semaine 2 : Home screen basique
- [ ] Créer `screens/home/home_screen.dart`
- [ ] Bottom navigation (Home, Groupes, Workouts, Nutrition, Profil)
- [ ] Dashboard simple (salut user.name, stats du jour)

### Semaine 3 : Groupes
- [ ] Écran liste groupes
- [ ] Écran créer groupe
- [ ] Écran rejoindre groupe (input code)
- [ ] Écran détail groupe (membres, programmes)

### Semaine 4 : Workouts
- [ ] Liste programmes du groupe
- [ ] Créer programme (formulaire dynamique)
- [ ] Démarrer session (UI de tracking)
- [ ] Historique perso

---

## Ressources essentielles

**Flutter Basics :**
- [Widget catalog](https://docs.flutter.dev/ui/widgets)
- [Layout cheatsheet](https://docs.flutter.dev/ui/layout)

**Firebase + Flutter :**
- [FlutterFire docs](https://firebase.flutter.dev/)
- [Firestore queries](https://firebase.google.com/docs/firestore/query-data/queries)

**State Management :**
- [Provider package](https://pub.dev/packages/provider)

**UI Inspiration :**
- [Dribbble fitness apps](https://dribbble.com/search/fitness-app)
- [Material Design 3](https://m3.material.io/)

---

## Besoin d'aide ?

**Erreurs communes :**

❌ `firebase_core` not initialized  
✅ Assure-toi que `Firebase.initializeApp()` est dans `main()` avant `runApp()`

❌ Permission denied (Firestore)  
✅ Vérifie les Firestore Rules (voir section 5)

❌ `The method 'XYZ' isn't defined`  
✅ Lance `flutter pub get` et redémarre l'IDE

---

## Tu es prêt !

Tu as tout pour commencer. Suis la roadmap semaine par semaine dans `README.md`.

**Conseil :** Commence simple, fais fonctionner un flow complet (auth → home → créer groupe), puis enrichis. Pas de computer vision au début. Focus sur la valeur : le partage en groupe.

Good luck ! 🚀
