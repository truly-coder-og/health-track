# 🚀 Push vers GitHub

## Étape 1 : Télécharge le code

Télécharge l'archive : `/root/clawd/fitness-app.tar.gz`

Ou récupère les fichiers individuellement depuis `/root/clawd/fitness-app/`

## Étape 2 : Sur ton ordinateur

```bash
# Si tu as téléchargé l'archive
tar -xzf fitness-app.tar.gz
cd fitness-app

# Ou si tu as copié les fichiers manuellement
cd fitness-app

# Vérifie que le repo git est initialisé
git status

# Ajoute le remote GitHub
git remote add origin https://github.com/truly-coder-og/health-track.git

# Renomme la branche en main (convention GitHub)
git branch -M main

# Push vers GitHub
git push -u origin main
```

## Étape 3 : Clone sur ta machine de dev

```bash
# Sur ton ordinateur ou autre machine
git clone https://github.com/truly-coder-og/health-track.git
cd health-track

# Continue avec le QUICK_START.md
```

---

## Alternative rapide : Créer le repo manuellement

Si tu préfères :

1. Va sur https://github.com/truly-coder-og/health-track
2. Upload files → glisse tout le dossier `fitness-app`
3. Commit
4. Clone sur ta machine de dev

---

Ensuite, suis le **QUICK_START.md** pour setup Flutter et Firebase !
