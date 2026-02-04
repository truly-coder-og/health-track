# Fitness App MVP - Plan de développement

## 🎯 Vision
Application mobile cross-platform (iOS/Android) pour suivi sportif et nutritionnel **avec partage en groupe**.

**Différenciateur clé :** Une personne crée un programme (sport ou nutrition), tout le groupe peut le suivre et personnaliser selon son profil.

---

## 📱 Stack technique retenue

### Frontend Mobile
**Flutter** (Dart)
- ✅ Un seul codebase pour iOS + Android
- ✅ Performance native
- ✅ UI riche et responsive
- ✅ Grande communauté, packages matures
- ✅ Hot reload = développement rapide

### Backend
**Firebase**
- **Firestore** : base de données NoSQL en temps réel
- **Authentication** : gestion users (email, Google, Apple Sign-In)
- **Storage** : photos de profil, images de repas
- **Cloud Functions** : logique serveur si besoin (invitations, notifications)
- **Gratuit** jusqu'à usage significatif (~50k lectures/jour)

### APIs externes
- **Open Food Facts API** : base nutritionnelle (gratuit)
- **Spoonacular API** : suggestions recettes (gratuit tier limité)

---

## 🏗️ Architecture MVP

### Collections Firestore

```
users/
  {userId}/
    - name
    - email
    - profilePicture
    - stats (weight, height, age, gender)
    - goals (perte poids, gain muscle, etc.)
    - groupIds[] (liste des groupes auxquels il appartient)

groups/
  {groupId}/
    - name
    - createdBy (userId)
    - members[] (userIds)
    - createdAt
    - type (fitness | nutrition | both)

workoutPrograms/
  {programId}/
    - groupId
    - createdBy (userId)
    - name
    - description
    - exercises[] (array d'objets)
      - name
      - sets
      - reps
      - restTime
      - notes
      - videoUrl (optionnel)
    - createdAt

userWorkoutLogs/
  {logId}/
    - userId
    - programId
    - date
    - exercises[] (copie du programme avec valeurs réelles)
      - completed: bool
      - actualSets
      - actualReps
      - weight (charge utilisée)
      - notes personnelles

mealPlans/
  {mealPlanId}/
    - groupId
    - createdBy
    - name
    - date
    - meals[] (breakfast, lunch, dinner, snacks)
      - name
      - ingredients[]
      - calories
      - macros (protein, carbs, fat)
      - recipe (optionnel)

userMealLogs/
  {logId}/
    - userId
    - mealPlanId (optionnel, null si repas perso)
    - date
    - mealType (breakfast, lunch, etc.)
    - foods[]
      - name
      - quantity
      - calories
      - macros
    - adjustments (notes perso)
```

---

## 🎨 Écrans principaux (wireframe mental)

### 1. Authentification
- Sign up / Login (email + Google/Apple)
- Onboarding : objectifs, stats de base

### 2. Dashboard (Home)
- Résumé du jour : calories, entraînement complété
- Quick actions : log workout, log meal
- Vue groupes actifs

### 3. Groupes
- Liste des groupes
- Créer/rejoindre groupe (via code invite)
- Vue détail groupe : membres, programmes partagés

### 4. Workouts
- **Programmes partagés** (par le groupe)
- **Mes logs** (historique personnel)
- Créer programme (si admin/créateur groupe)
- Démarrer session (timer, tracking en live)

### 5. Nutrition
- **Plans de repas partagés** (groupe)
- **Mon journal** (logs persos)
- Scanner code-barre (future)
- Suggestions recettes (future)

### 6. Profil
- Stats perso
- Objectifs
- Paramètres

---

## 🛤️ Roadmap de développement

### Semaine 1-2 : Setup + Apprentissage
- [ ] Installer Flutter SDK
- [ ] Cours Flutter basics (widgets, state management)
- [ ] Setup Firebase project
- [ ] Créer app Flutter vierge, connecter Firebase

### Semaine 3-4 : Authentication
- [ ] Écrans login/signup UI
- [ ] Firebase Auth intégration
- [ ] Onboarding flow (collecte stats de base)
- [ ] Profil user basique

### Semaine 5-6 : Groupes (CORE)
- [ ] Créer groupe
- [ ] Système d'invitation (code unique ou lien)
- [ ] Rejoindre groupe
- [ ] Vue liste membres
- [ ] Firestore rules (sécurité : seuls membres accèdent)

### Semaine 7-9 : Workouts
- [ ] Créer programme d'entraînement (formulaire)
- [ ] Afficher programmes du groupe
- [ ] Logger une session (copier programme, remplir valeurs)
- [ ] Historique personnel
- [ ] Modifier/supprimer (seulement créateur)

### Semaine 10-12 : Nutrition basique
- [ ] Créer plan de repas groupe
- [ ] Logger repas perso (manuel)
- [ ] Calcul calories/macros
- [ ] Historique nutrition

### Semaine 13-14 : Polish + Tests
- [ ] Design cohérent (thème, couleurs)
- [ ] Gestion erreurs
- [ ] Tests avec amis (beta fermée)
- [ ] Corrections bugs

### Semaine 15-16 : Déploiement
- [ ] Build iOS (TestFlight)
- [ ] Build Android (Google Play Beta)
- [ ] Préparer assets (screenshots, description)
- [ ] Lancer beta publique

---

## 💡 Fonctionnalités post-MVP (Phase 2+)

**Nutrition avancée :**
- Scanner codes-barres (ML Kit)
- Intégration Open Food Facts
- Suggestions recettes selon ingrédients

**Social :**
- Feed groupe (posts, progress pics)
- Challenges entre membres
- Leaderboards

**IA/ML (Phase 3) :**
- Computer vision correction posture
- Recommandations personnalisées

**Monétisation :**
- Freemium : 1 groupe, fonctions basiques
- Premium (5€/mois) : groupes illimités, stats avancées, recettes, export données

---

## 🧰 Ressources pour démarrer

### Apprendre Flutter
- [Flutter Codelabs](https://docs.flutter.dev/codelabs) (officiel, excellent)
- [Flutter & Firebase Course](https://www.youtube.com/watch?v=sfA3NWDBPZ4) (gratuit, Andrea Bizzotto)
- [Fireship.io Flutter basics](https://www.youtube.com/watch?v=1ukSR1GRtMU) (rapide, 30min)

### State Management
Pour MVP : **Provider** (simple, officiel)
Plus tard : Riverpod ou Bloc si nécessaire

### Design
- Material Design 3 (intégré Flutter)
- [Figma Community](https://www.figma.com/community) pour inspiration UI fitness apps

### Firebase
- [FlutterFire docs](https://firebase.flutter.dev/) (intégration officielle)
- Setup : Authentication, Firestore, Storage

---

## 📊 Estimation coûts

### Développement
- **Temps :** 3-4 mois (temps partiel, solo)
- **Coût dev :** 0€ (toi)

### Infrastructure
- **Firebase :** 0€ (Spark plan gratuit jusqu'à ~5k users actifs/mois)
- **Apple Developer :** 99$/an (~92€)
- **Google Play :** 25$ one-time (~23€)

### Total première année : ~120€

---

## 🚀 Prochaines étapes concrètes

1. **Installe Flutter** : https://docs.flutter.dev/get-started/install
2. **Crée Firebase project** : https://console.firebase.google.com
3. **Clone structure** : je vais te créer la structure de dossiers initiale
4. **Suis roadmap semaine par semaine**

Prêt à commencer ? Je te prépare la structure initiale du projet ?
