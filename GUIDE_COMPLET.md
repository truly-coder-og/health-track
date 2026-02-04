# 🏋️ FitTogether - Guide Complet

## 📱 L'App

**FitTogether** est une application mobile de suivi fitness et nutrition **collaborative**. Crée des groupes avec tes amis, partagez vos programmes d'entraînement, et suivez votre progression ensemble.

### ✨ Fonctionnalités principales

- 👥 **Groupes** : Créer, rejoindre, inviter des amis
- 💪 **Workouts** : Programmes partagés + tracking sessions avec timer
- 🥗 **Nutrition** : Log repas + macros + historique
- 📊 **Dashboard** : Stats du jour en temps réel
- 📴 **Offline-first** : Tes logs perso fonctionnent sans réseau

---

## 🚀 Installation & Setup

### Prérequis

- **Flutter** : Version 3.0+ ([installer](https://docs.flutter.dev/get-started/install))
- **Dart** : Inclus avec Flutter
- **Android Studio** / **Xcode** (selon plateforme)
- **Supabase** : Compte gratuit ([créer](https://supabase.com/dashboard))

### 1. Cloner le repo

```bash
git clone https://github.com/truly-coder-og/health-track.git
cd health-track
git checkout supabase-refactor
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configurer Supabase

#### a) Créer un projet Supabase

1. Va sur https://supabase.com/dashboard
2. Clique "New Project"
3. Nom : `fitness-app` (ou autre)
4. Note **Project URL** et **anon public key**

#### b) Créer les tables

Va dans **SQL Editor** et exécute :

```sql
-- Users (profils)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Groups
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('fitness', 'nutrition', 'both')),
  description TEXT,
  invite_code TEXT UNIQUE NOT NULL,
  created_by UUID REFERENCES users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Group members
CREATE TABLE group_members (
  group_id UUID REFERENCES groups ON DELETE CASCADE,
  user_id UUID REFERENCES users ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);

-- Workout programs
CREATE TABLE workout_programs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES groups ON DELETE CASCADE,
  created_by UUID REFERENCES users NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  exercises JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_programs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users: read all, update own
CREATE POLICY "Users can read all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Groups: read if member, create if authenticated
CREATE POLICY "Members can read group" ON groups FOR SELECT 
  USING (id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid()));
CREATE POLICY "Anyone can create group" ON groups FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Group members: read if member
CREATE POLICY "Members can see members" ON group_members FOR SELECT
  USING (group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid()));
CREATE POLICY "Can join group" ON group_members FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Workout programs: read if group member, create if authenticated
CREATE POLICY "Members can read programs" ON workout_programs FOR SELECT
  USING (group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid()));
CREATE POLICY "Can create program" ON workout_programs FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
```

#### c) Configurer Authentication

1. **Settings** → **Authentication**
2. Active **Email** provider
3. (Optionnel) Configure email templates

### 4. Ajouter tes clés Supabase

```bash
# Copie le fichier exemple
cp lib/config/supabase_config.dart.example lib/config/supabase_config.dart

# Édite le fichier
nano lib/config/supabase_config.dart
```

Remplace avec tes vraies clés :

```dart
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY_HERE';
}
```

⚠️ **Ne commit jamais ce fichier !** Il est déjà dans `.gitignore`.

### 5. Générer les fichiers Drift (SQLite)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Lancer l'app

```bash
# Liste les devices disponibles
flutter devices

# Lance sur Android
flutter run -d <device_id>

# Ou sur iOS
flutter run -d <device_id>

# Ou sur Chrome (web)
flutter run -d chrome
```

---

## 📖 Guide d'utilisation

### Premier lancement

1. **Signup** : Crée ton compte (nom, email, password)
2. **Login** : Connecte-toi
3. **Dashboard** : Tu arrives sur le dashboard

### Créer un groupe

1. Va dans **Groupes** (onglet 2)
2. Clique **+ Créer un groupe**
3. Entre un nom (ex: "Team Running")
4. Choisis le type : Sport, Nutrition, ou Both
5. **Note le code d'invitation** (ex: `ABC123`)
6. Partage-le avec tes amis

### Rejoindre un groupe

1. **Groupes** → **Icône "Rejoindre"** (en haut)
2. Entre le code d'invitation
3. Clique **Rejoindre**
4. Tu fais maintenant partie du groupe !

### Créer un programme d'entraînement

1. **Groupes** → Détails groupe → **Programmes d'entraînement**
2. Clique **+ Nouveau programme**
3. Entre un nom (ex: "Full Body")
4. Ajoute des exercices :
   - Nom : Squat
   - Séries : 3
   - Reps : 10
   - Repos : 60s
5. Clique **+ Ajouter** pour plus d'exercices
6. **Créer le programme**
7. Tous les membres du groupe le voient !

### Démarrer une session d'entraînement

1. **Programmes** → Sélectionne un programme
2. Clique **Démarrer la session**
3. Le timer démarre automatiquement
4. Coche chaque série complétée
5. Clique **Terminer la session**
6. Ta session est enregistrée en local (offline) !

### Logger un repas

1. **Nutrition** (onglet 4)
2. Choisis le type de repas (Petit-déj, Déjeuner, Dîner, Snack)
3. Clique **+** ou **Logger un repas**
4. Entre :
   - Nom : Poulet-riz
   - Calories : 500
   - Protéines : 40g
   - Glucides : 50g
   - Lipides : 10g
5. **Enregistrer**
6. Les totaux du jour se mettent à jour automatiquement !

### Voir l'historique

**Nutrition :**
- **Nutrition** → **Icône Historique** (en haut)
- Voit les 30 derniers jours groupés par date

**Workouts :**
- Tes sessions sont stockées localement
- (Visualisation à venir)

---

## 🏗️ Architecture

### Stack technique

- **Frontend** : Flutter (Dart)
- **Cloud Backend** : Supabase (PostgreSQL + Auth + Realtime)
- **Local Database** : SQLite (Drift ORM)
- **State Management** : Provider

### Pourquoi offline-first ?

- **Workouts & Nutrition** → SQLite local (fonctionne sans réseau)
- **Groups & Programs** → Supabase cloud (partagé entre membres)

**Résultat** : ~95% de l'app fonctionne offline !

### Structure du code

```
lib/
├── config/
│   └── supabase_config.dart (tes clés)
├── database/
│   └── local_database.dart (SQLite schema)
├── models/
│   ├── user_model.dart
│   ├── group_model.dart
│   └── workout_program.dart
├── providers/
│   ├── auth_provider.dart
│   ├── groups_provider.dart
│   ├── workouts_provider.dart
│   └── nutrition_provider.dart
├── screens/
│   ├── auth/ (login, signup)
│   ├── home/ (dashboard, navigation)
│   ├── groups/ (liste, créer, rejoindre, détails)
│   ├── workouts/ (programmes, session tracking)
│   └── nutrition/ (dashboard, log repas, historique)
├── services/
│   └── supabase_service.dart (API calls)
└── main.dart
```

---

## 🐛 Debugging

### Problèmes courants

#### ❌ "firebase_core not initialized"
✅ **Solution** : Assure-toi que `supabase_config.dart` existe avec tes vraies clés.

#### ❌ "Permission denied (Firestore)"
✅ **Solution** : Vérifie les RLS policies dans Supabase (voir section 3b).

#### ❌ "The method 'XYZ' isn't defined"
✅ **Solution** : 
```bash
flutter pub get
flutter clean
flutter pub run build_runner build --delete-conflicting-outputs
```

#### ❌ Pas de données après login
✅ **Solution** : Les tables Supabase sont peut-être vides. Vérifie le SQL Editor.

### Logs utiles

```bash
# Voir les logs en temps réel
flutter run --verbose

# Nettoyer le cache
flutter clean
rm -rf build/

# Rebuild
flutter pub get
flutter run
```

---

## 🚀 Prochaines étapes (suggestions)

### Features à ajouter

- 📈 **Graphiques stats** (poids, calories sur 7j)
- 📸 **Photos de repas** (scan + OCR)
- 🔔 **Notifications** (rappels workout, encouragements)
- 🏆 **Challenges groupe** (qui fait le plus de workouts cette semaine ?)
- 💬 **Chat groupe** (commentaires sur programmes)
- 🌐 **Sync entre devices** (via Supabase realtime)

### Déploiement

#### TestFlight (iOS)
1. Crée un compte Apple Developer (99$/an)
2. Configure Xcode signing
3. `flutter build ipa`
4. Upload via Xcode → TestFlight

#### Google Play Beta (Android)
1. Crée un compte Google Play Developer (25$ one-time)
2. `flutter build appbundle`
3. Upload sur Google Play Console → Internal Testing

---

## 📄 License

MIT License - Fais-en ce que tu veux !

---

## 🙏 Crédits

Conçu et développé pour te permettre de t'entraîner avec tes potes.

Si tu améliores l'app, partage tes modifs ! 🚀

**Bon workout ! 💪**
