# 🎯 MVP Scope - Version Testable

## Objectif
Application fonctionnelle que tu peux tester avec 5-10 amis pour valider le concept de **partage en groupe**.

---

## ✅ Fonctionnalités incluses

### 1. Auth & Profil (Supabase cloud)
- [x] Signup email/password
- [x] Login
- [x] Profil utilisateur (nom, email, avatar optionnel)
- [x] Stats de base (poids, taille, âge, objectif)
- [ ] Onboarding initial (collecte stats)

### 2. Groupes (Supabase cloud - CORE)
- [ ] Créer groupe (nom, type: sport/nutrition/both)
- [ ] Code d'invitation unique
- [ ] Rejoindre groupe via code
- [ ] Liste mes groupes
- [ ] Voir membres du groupe
- [ ] Quitter groupe

### 3. Programmes Workout (Supabase → cache local)
- [ ] Voir programmes du groupe
- [ ] Créer programme (nom + liste exercices)
  - Exercice : nom, séries, reps, repos, notes
- [ ] Supprimer programme (si créateur)
- [ ] **Télécharger en local** (cache)

### 4. Sessions Workout (SQLite local)
- [ ] Démarrer session depuis programme
- [ ] Timer entre séries
- [ ] Logger séries complétées (reps, poids)
- [ ] Sauvegarder session (local)
- [ ] Voir historique perso (local)

### 5. Nutrition basique (SQLite local)
- [ ] Logger repas manuel
  - Nom, calories, protéines, glucides, lipides
- [ ] Historique repas (local)
- [ ] Stats jour (calories totales, macros)

### 6. Stats personnelles (SQLite local)
- [ ] Enregistrer poids (tracking)
- [ ] Graph poids (30 derniers jours)
- [ ] Stats globales (séances complétées, calories moyennes)

---

## ❌ Hors scope MVP (Phase 2+)

- ❌ Computer vision (posture)
- ❌ Scan code-barre aliments
- ❌ Suggestions recettes IA
- ❌ Feed social / posts
- ❌ Challenges / leaderboards
- ❌ Photos de repas
- ❌ Export données
- ❌ Dark mode
- ❌ Notifications push
- ❌ Plans de repas partagés (focus workouts d'abord)

---

## 🧪 Test du MVP

### Scénario de test avec amis

**Jour 1 : Setup**
1. Toi : Crée compte → Crée groupe "Muscu Copains"
2. Toi : Crée programme "Full Body Débutant"
   - Squats : 3x10
   - Pompes : 3x12
   - Planche : 3x30s
3. Toi : Partage code invite (ex: "ABC123")

**Jour 2 : Amis rejoignent**
4. Ami 1 : Crée compte → Rejoint groupe via "ABC123"
5. Ami 1 : Voit programme "Full Body Débutant"
6. Ami 1 : Démarre session → Log ses séries
7. Ami 1 : Voit son historique

**Jour 3 : Personnalisation**
8. Ami 2 : Rejoint groupe
9. Ami 2 : Fait le même programme mais ajuste (3x8 au lieu de 3x10)
10. Ami 2 : Log nutrition (repas post-workout)

**Jour 7 : Validation**
11. Toi : Crée nouveau programme "Upper Body"
12. Tous : Refresh → voient nouveau programme
13. Stats perso : graphiques de progrès individuels

### Métriques de succès
- ✅ 3+ personnes utilisent l'app activement
- ✅ Au moins 1 programme partagé suivi par tous
- ✅ Chacun a logé 3+ sessions
- ✅ L'app fonctionne offline (logger workout sans connexion)
- ✅ Feedback positif sur le partage en groupe

---

## 📱 Écrans du MVP (UI)

### Navigation principale (Bottom tabs)
1. **Home** - Dashboard perso (stats du jour, prochaine session)
2. **Groupes** - Liste groupes, créer/rejoindre
3. **Workouts** - Programmes + historique
4. **Nutrition** - Log repas + stats
5. **Profil** - Stats perso, paramètres

### Flux détaillé

```
Auth Flow:
Login → Signup → Onboarding (stats) → Home

Groupes Flow:
Liste groupes → Détail groupe (membres + programmes)
             → Créer groupe
             → Rejoindre groupe (input code)

Workout Flow:
Programmes groupe → Détail programme → Démarrer session
                                    → Session active (timer)
                                    → Résumé session
                                    → Historique

Nutrition Flow:
Log repas (form) → Historique jour → Stats
```

---

## 🚀 Timeline réaliste

### Setup initial (1 semaine)
- Supabase setup
- SQLite local (Drift)
- Auth refonte
- Structure UI de base

### Groupes (1 semaine)
- CRUD groupes
- Invitations
- UI liste/détail

### Workouts (2 semaines)
- Programmes partagés
- Session tracking
- Historique local

### Nutrition + Stats (1 semaine)
- Log repas basique
- Graphiques simples

### Polish + Tests (1 semaine)
- UI/UX
- Corrections bugs
- Beta avec amis

**Total : 6 semaines** (temps partiel)

---

## 💰 Coût estimé MVP

### Développement
- Temps : 6 semaines × temps partiel = **0€** (toi)

### Infrastructure
- Supabase : **0€** (free tier)
- SQLite : **0€** (local)
- Apple Developer : **99$/an** (obligatoire iOS)
- Google Play : **25$** (one-time)

**Total première année : ~120€**

### Si 100 users actifs
- 100 users × 50 requêtes/mois = 5k requêtes
- **0€** (largement dans le free tier Supabase)

### Si 1000 users actifs
- 1000 users × 20 requêtes/mois = 20k requêtes
- **0€** (toujours gratuit)

### Si 5000 users actifs
- 5000 users × 10 requêtes/mois = 50k requêtes
- **0€** (juste à la limite)

**À 10k users** → peut-être upgrade Supabase Pro (25$/mois)

---

## 🎬 Validation avant scale

**Avant d'investir dans features avancées :**

1. **100 users organiques** utilisent l'app 1 mois
2. **Retention 30% minimum** (reviennent après 1 semaine)
3. **Feedback positif** sur le partage groupe
4. **Au moins 20% ont créé un groupe**

Si ✅ → développe nutrition avancée, scan, recettes
Si ❌ → pivot ou abandon (tu auras investi que ton temps)

---

## 🧠 Pourquoi ce scope ?

**Trop d'apps échouent car :**
- Trop de features → jamais fini
- Pas de différenciateur clair
- Pas testé avec vrais users

**Ce MVP :**
- ✅ Focus sur TON différenciateur (partage groupe)
- ✅ Testable en 6 semaines
- ✅ Validable avec 10 amis
- ✅ Coût = 0€

Si ça marche, tu enrichis. Si ça marche pas, tu sais pourquoi sans avoir dépensé 10k€.
