# 🔄 Refactor Summary - Firebase → Supabase + SQLite

## ✅ Ce qui a été fait

### 1. Architecture repensée (Offline-first)
- **Cloud (Supabase)** : Auth, groupes, programmes partagés seulement
- **Local (SQLite/Drift)** : Logs workouts, nutrition, stats perso
- **Résultat** : ~95% offline, coût serveur minimal

### 2. Documentation complète
- `OFFLINE_FIRST_ARCHITECTURE.md` - Concept et stratégie
- `MVP_SCOPE.md` - Fonctionnalités exactes du MVP
- `SUPABASE_SETUP.md` - Setup database complet (schema SQL + RLS)
- `pubspec_dependencies.yaml` - Dépendances Flutter

### 3. Service Supabase créé
- `services/supabase_service.dart` - Toutes les opérations cloud
  - Auth (signup, login, logout, reset)
  - Groupes (créer, rejoindre, lister, quitter)
  - Workout programs (CRUD)
  - Meal plans (optionnel phase 2)

---

## 🎯 MVP Scope Final

### Fonctionnalités (6 semaines dev)
1. **Auth** - Signup/Login (Supabase)
2. **Groupes** - Créer, rejoindre via code, voir membres
3. **Workouts** - Programmes partagés + sessions perso offline
4. **Nutrition** - Log repas basique (local)
5. **Stats** - Graphiques poids, calories (local)

### Test avec amis
- Toi : crée groupe + programme
- 5 amis : rejoignent + utilisent
- Validation : tout le monde log 3+ sessions
- Feedback sur partage groupe

---

## 💰 Coût réel estimé

### Infrastructure (gratuit jusqu'à...)
- **Supabase** : 0€ jusqu'à 50k requêtes API/mois
- **SQLite** : 0€ (local device)
- **Stockage photos** : 1 GB gratuit (largement suffisant MVP)

### Scénarios
- **100 users actifs** : ~5k requêtes/mois → **0€**
- **1000 users actifs** : ~20k requêtes/mois → **0€**
- **5000 users actifs** : ~50k requêtes/mois → **0€** (limite)
- **10k+ users** : upgrade Supabase Pro 25$/mois → **300€/an**

### Fees obligatoires
- Apple Developer : 99$/an (~92€)
- Google Play : 25$ one-time (~23€)
- **Total première année : ~115€**

---

## 🚧 Ce qu'il reste à faire

### Code à créer
1. **SQLite local database (Drift)**
   - Tables : workout_logs, meal_logs, user_stats
   - Service local_database.dart

2. **Écrans UI**
   - Signup screen
   - Home dashboard
   - Groupes (liste, créer, rejoindre, détail)
   - Workouts (liste programmes, session tracking, historique)
   - Nutrition (log repas, stats)
   - Profil

3. **Main.dart refonte**
   - Init Supabase
   - Init Drift
   - Navigation principale (Bottom tabs)

4. **État/Provider**
   - AuthProvider (stream Supabase auth)
   - UserProvider (profil)
   - GroupsProvider (liste groupes)

---

## 🎬 Prochaines étapes (ordre)

### Phase 1 : Setup technique (3 jours)
1. Créer projet Supabase (SUPABASE_SETUP.md)
2. Flutter : ajouter dépendances (`pubspec_dependencies.yaml`)
3. Créer local database (Drift schema)
4. Refonte main.dart avec Supabase init

### Phase 2 : Auth UI (2 jours)
5. Signup screen
6. Login screen (adapter existant)
7. Onboarding (stats de base)

### Phase 3 : Groupes (5 jours)
8. Home screen avec liste groupes
9. Créer groupe (form)
10. Rejoindre groupe (input code)
11. Détail groupe (membres)

### Phase 4 : Workouts (7 jours)
12. Liste programmes groupe
13. Créer programme (form dynamique)
14. Session tracking (timer, log séries)
15. Historique local

### Phase 5 : Nutrition + Stats (5 jours)
16. Log repas (form basique)
17. Stats jour/semaine
18. Graph poids (fl_chart)

### Phase 6 : Polish (3 jours)
19. UI/UX cohérent
20. Gestion erreurs
21. Tests avec amis

**Total : ~25 jours (6 semaines temps partiel)**

---

## 📊 Comparaison avant/après

| Aspect | Firebase (avant) | Supabase + SQLite (après) |
|--------|-----------------|---------------------------|
| **Coût 1k users** | ~10-20€/mois | 0€ |
| **Stockage local** | Cache basique | Database complète offline |
| **Requêtes/user/mois** | ~100 (tout cloud) | ~10-20 (sync minimale) |
| **Fonctionne offline** | Partiellement | Totalement (logs perso) |
| **Facturation surprise** | Possible | Non (pause service) |
| **Self-host possible** | Non | Oui (Supabase open-source) |
| **Type DB** | NoSQL (Firestore) | SQL (PostgreSQL) |

---

## 🧪 Comment tester le MVP

### Setup
1. **Toi** : Crée compte → Crée groupe "Test Crew"
2. **Toi** : Crée programme "Full Body" (3 exercices)

### Inviter amis
3. Share code invite (ex: "FIT123")
4. **5 amis** : Install app → Signup → Join "FIT123"

### Utilisation
5. **Tous** : Voient programme "Full Body"
6. **Tous** : Font 1 session (log séries/reps)
7. **Toi** : Crée 2e programme "Upper Body"
8. **Tous** : Pull refresh → voient nouveau programme

### Validation
- ✅ Chacun a logé 3+ sessions
- ✅ Programmes partagés synchronisés
- ✅ App fonctionne offline (logs perso)
- ✅ Feedback positif groupe

---

## 🚀 Déploiement final

### Beta (semaine 7)
- TestFlight (iOS) : 100 beta testers max
- Google Play Beta : distribution fermée

### Production (semaine 8+)
- App Store review (~2-7 jours)
- Google Play review (~1-3 jours)
- Launch !

---

## 💡 Prêt à coder ?

**Option A** : Je te crée toute la base Drift (SQLite local) maintenant

**Option B** : Tu setup Supabase d'abord, on test auth, puis on continue

**Recommandation** : Option B (étape par étape, tu valides chaque partie)

Dis-moi et on y va ! 🚀
