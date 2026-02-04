# 🏋️ FitTogether

> L'app collaborative pour s'entraîner et manger mieux **ensemble**.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Powered-green.svg)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Ce que fait FitTogether

- 👥 **Créer des groupes** avec tes amis
- 💪 **Partager des programmes** d'entraînement
- ⏱️ **Tracker tes sessions** avec timer live
- 🥗 **Logger tes repas** et macros
- 📊 **Voir tes stats** quotidiennes
- 📴 **Fonctionne offline** (SQLite local)

**Différence vs autres apps** : Tout est pensé pour le **groupe**, pas juste l'individu.

---

## 🚀 Quick Start

```bash
# 1. Clone
git clone https://github.com/truly-coder-og/health-track.git
cd health-track
git checkout supabase-refactor

# 2. Install
flutter pub get

# 3. Configure Supabase (voir GUIDE_COMPLET.md)
cp lib/config/supabase_config.dart.example lib/config/supabase_config.dart
# Édite avec tes clés Supabase

# 4. Generate SQLite code
flutter pub run build_runner build

# 5. Run
flutter run
```

**📖 Guide complet** : [GUIDE_COMPLET.md](./GUIDE_COMPLET.md)

---

## 📱 Screenshots

### Dashboard
![Dashboard](./screenshots/dashboard.png)
> Stats du jour en temps réel

### Groupes
![Groupes](./screenshots/groups.png)
> Créer, rejoindre, inviter des amis

### Workouts
![Workout Session](./screenshots/workout.png)
> Tracker tes séries avec timer live

### Nutrition
![Nutrition](./screenshots/nutrition.png)
> Logger repas + macros

---

## 🏗️ Stack

- **Frontend** : Flutter (Dart)
- **Cloud** : Supabase (PostgreSQL + Auth + Realtime)
- **Local** : SQLite (Drift ORM)
- **State** : Provider

**Pourquoi offline-first ?**  
Tes logs perso (workouts, nutrition) fonctionnent sans réseau. Seuls les groupes/programmes nécessitent internet.

---

## 🎯 Use Cases

### Training camps
> Groupe cycliste en altitude : tout le monde voit les programmes, track ses sessions, compare sa nutrition.

### Groupes d'amis
> Tu pars en trek avec 5 potes : partagez un programme "Mountain Training", loggez vos sessions.

### Coaching
> Coach crée programmes pour son équipe, chacun track individuellement.

---

## 📊 Features

| Feature | Status |
|---------|--------|
| Auth (signup/login) | ✅ |
| Groupes (créer/rejoindre) | ✅ |
| Programmes workouts | ✅ |
| Session tracking (timer) | ✅ |
| Nutrition (repas + macros) | ✅ |
| Historique 30j | ✅ |
| Dashboard stats | ✅ |
| Offline-first | ✅ |
| Graphiques stats | ⏳ (à venir) |
| Photos repas | ⏳ (à venir) |
| Challenges groupe | ⏳ (à venir) |

---

## 🤝 Contributing

Les contributions sont les bienvenues !

1. Fork le projet
2. Crée une branche (`git checkout -b feature/amazing-feature`)
3. Commit (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Ouvre une Pull Request

---

## 📝 License

MIT License - Fais-en ce que tu veux ! Voir [LICENSE](LICENSE).

---

## 💪 Get Started

1. **Lis le guide** : [GUIDE_COMPLET.md](./GUIDE_COMPLET.md)
2. **Setup Supabase** : [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)
3. **Run l'app** : `flutter run`
4. **Entraîne-toi** ! 🚀

---

**Made with 💙 for people who train together.**
