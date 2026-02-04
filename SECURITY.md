# 🔒 Sécurité - Configuration Supabase

## ⚠️ IMPORTANT : Ne jamais commit les clés API

Le fichier `lib/config/supabase_config.dart` contient tes clés Supabase et **NE DOIT PAS** être versionné.

### Setup initial

1. **Copie le fichier exemple :**
   ```bash
   cp lib/config/supabase_config.dart.example lib/config/supabase_config.dart
   ```

2. **Remplace les valeurs** dans `supabase_config.dart` :
   - Va sur https://supabase.com/dashboard
   - Sélectionne ton projet
   - Settings → API
   - Copie :
     - `Project URL` → `SupabaseConfig.url`
     - `anon public` key → `SupabaseConfig.anonKey`

3. **Vérifie que c'est ignoré par Git :**
   ```bash
   git status
   # supabase_config.dart ne doit PAS apparaître
   ```

### Si tu as déjà commit les clés (OOPS!)

1. **Régénère tes clés Supabase :**
   - Dashboard → Settings → API
   - Reset `anon` key (bouton "Reset")

2. **Nettoie l'historique Git :**
   ```bash
   # Supprime le fichier de l'historique
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch lib/config/supabase_config.dart" \
     --prune-empty --tag-name-filter cat -- --all
   
   # Force push (écrase l'historique)
   git push origin --force --all
   ```

3. **Mets à jour ton fichier local** avec les nouvelles clés.

### Protection supplémentaire (Supabase Dashboard)

Active **RLS (Row Level Security)** pour limiter l'accès aux données même si quelqu'un vole ta clé `anon`.

- Database → Tables → Chaque table → Enable RLS
- Crée des policies (voir `SUPABASE_SETUP.md`)

---

**Résumé :** `supabase_config.dart` = secret, ne jamais push !
