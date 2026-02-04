# 🔌 Architecture Offline-First (Coût Zéro)

## Principe

**80% offline** → données locales (SQLite sur le téléphone)  
**20% online** → sync essentiel (auth, groupes, programmes partagés)

Avantages :
- ✅ Fonctionne sans connexion
- ✅ Coût serveur quasi nul
- ✅ Ultra rapide (pas de latence réseau)
- ✅ Vie privée (données perso sur l'appareil)

---

## 📦 Nouvelle Stack

### Backend : **Supabase** (gratuit)
- Auth (email/password)
- PostgreSQL pour partage (groupes, programmes)
- Storage pour avatars (optionnel)

### Local : **SQLite** (Hive ou Drift)
- Logs d'entraînement
- Logs nutrition
- Stats personnelles
- Cache programmes

### Sync : **Stratégie hybride**
- **Jamais sync** : logs persos, stats quotidiennes
- **Sync read-only** : programmes du groupe (téléchargés 1x)
- **Sync minimal** : création groupe, invitation

---

## 🗂️ Répartition données

### Stockage LOCAL (SQLite) - GRATUIT
```
userWorkoutLogs/        ← Toutes tes sessions
userMealLogs/           ← Tous tes repas
userStats/              ← Poids, mesures, progrès
cachedPrograms/         ← Copie locale des programmes groupe
settings/               ← Préférences
```

### Stockage CLOUD (Supabase) - Minimal
```
users/                  ← Profil public (nom, avatar)
groups/                 ← Infos groupe
workoutPrograms/        ← Programmes partagés (read-only après création)
mealPlans/              ← Plans repas partagés (read-only)
```

**Estimation :**
- 1 user = ~5 KB dans Supabase
- 1 groupe + 10 programmes = ~50 KB
- 1000 users actifs = **50 MB** (sur 500 MB gratuits)

---

## 🔄 Flux de synchronisation

### 1. Première connexion
```
1. Auth via Supabase
2. Télécharge groupes de l'user
3. Télécharge programmes des groupes → stocke en local
4. Tout le reste = local
```

### 2. Utilisation quotidienne (100% offline)
```
- Log workout → SQLite local
- Log repas → SQLite local
- Voir stats → SQLite local
- Voir programmes → Cache SQLite
```

### 3. Actions sociales (rare)
```
- Créer groupe → POST Supabase
- Rejoindre groupe → POST Supabase + download programmes
- Nouveau programme créé → POST Supabase
- Refresh programmes groupe → GET Supabase (pull manuel)
```

---

## 💾 Packages Flutter

### SQLite local
```yaml
dependencies:
  # Option 1 : Drift (SQL type-safe, recommandé)
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  
  # Option 2 : Hive (NoSQL simple)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

### Supabase
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

**Bonus :** Drift + Supabase = combo parfait (Drift gère l'offline, Supabase le partage).

---

## 🎯 Stratégie de sync intelligente

### Pull refresh manuel
Au lieu de sync temps réel (coûteux), l'user refresh manuellement :

```dart
// Bouton "Rafraîchir programmes" dans l'écran groupe
onPressed: () async {
  final programs = await supabase
    .from('workout_programs')
    .select()
    .eq('group_id', groupId);
  
  // Stocke en local
  await localDB.updateCachedPrograms(programs);
}
```

### Notifications push (optionnel, gratuit)
Si membre crée nouveau programme :
- **OneSignal** (gratuit 10k push/mois)
- Notif → user ouvre app → pull nouveau programme

---

## 💰 Estimation coûts réelle

### Gratuit (illimité)
- SQLite local : 0€
- Supabase free tier : 0€ jusqu'à 50k requêtes/mois
- OneSignal push : 0€ jusqu'à 10k/mois

### Si tu dépasses (improbable au début)
**Scénario : 5000 users actifs**

Requêtes/mois :
- 5000 logins/mois = 5k requêtes
- 1000 créations programme/mois = 1k requêtes
- 10k refreshes groupe/mois = 10k requêtes
= **16k requêtes/mois** (sur 50k gratuits)

**Conclusion :** Tu peux avoir **plusieurs milliers d'users** sans payer.

---

## 🚀 Migration depuis Firebase

Je vais te recréer l'archi avec Supabase + SQLite local. Ça change :

**Remplacer :**
- `firebase_auth` → `supabase_flutter` (auth)
- `cloud_firestore` → `supabase_flutter` (base cloud)
- Rien → `drift` (base locale)

**Services à refaire :**
- `auth_service.dart` → adapté Supabase
- `database_service.dart` → split en `cloud_service.dart` + `local_database.dart`

---

## ⚡ Avantages bonus Supabase

1. **Vraie DB SQL** → requêtes complexes, relations, joins
2. **Row Level Security** → sécurité native (pas besoin rules custom)
3. **Realtime optionnel** → si besoin plus tard
4. **Self-host possible** → si croissance = deploy ton instance
5. **Edge Functions** → équivalent Cloud Functions (gratuit 500k invocations/mois)

---

## 🎬 Prochaine étape

Tu veux que je :
1. **Refasse l'archi complète** avec Supabase + Drift/SQLite ?
2. **Garde Firebase** mais avec caching agressif offline ?
3. **Mix** : Firebase auth (simple) + SQLite local (zéro sync) ?

**Recommandation :** Option 1 (Supabase + Drift). C'est l'archi optimale pour ton cas.

Dis-moi et je te recréé tout le code !
