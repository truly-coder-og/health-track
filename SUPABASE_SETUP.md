# 🔧 Supabase Setup Guide

## 1. Créer projet Supabase

1. Va sur https://supabase.com
2. Sign up (gratuit, pas de CB requise)
3. "New Project"
   - Name: `fitness-app`
   - Database Password: (note-le, tu en auras besoin)
   - Region: choisir proche de toi (ex: Europe West)
4. Attends ~2min (création DB)

---

## 2. Récupérer les clés API

Dans ton projet Supabase :
- Settings → API

Tu as besoin de :
- **Project URL** : `https://xxx.supabase.co`
- **anon public key** : `eyJhbGc...` (longue clé)

---

## 3. Schema Database (SQL)

Dans Supabase → SQL Editor → New query, copie ce SQL :

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (profil public uniquement)
CREATE TABLE users (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  profile_picture TEXT,
  weight DECIMAL,
  height DECIMAL,
  age INTEGER,
  gender TEXT,
  primary_goal TEXT,
  target_weight DECIMAL,
  weekly_workouts INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Groups table
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('fitness', 'nutrition', 'both')),
  created_by UUID REFERENCES users(id) NOT NULL,
  invite_code TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group members (relation many-to-many)
CREATE TABLE group_members (
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);

-- Workout programs (partagés dans groupe)
CREATE TABLE workout_programs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE NOT NULL,
  created_by UUID REFERENCES users(id) NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  exercises JSONB NOT NULL, -- Array d'objets exercises
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Meal plans (optionnel, phase 2)
CREATE TABLE meal_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE NOT NULL,
  created_by UUID REFERENCES users(id) NOT NULL,
  name TEXT NOT NULL,
  date DATE,
  meals JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes pour performance
CREATE INDEX idx_group_members_user ON group_members(user_id);
CREATE INDEX idx_group_members_group ON group_members(group_id);
CREATE INDEX idx_workout_programs_group ON workout_programs(group_id);
CREATE INDEX idx_meal_plans_group ON meal_plans(group_id);

-- Trigger pour auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_programs_updated_at BEFORE UPDATE ON workout_programs
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

**Run** le script.

---

## 4. Row Level Security (RLS)

Supabase utilise PostgreSQL RLS pour sécuriser les données.

Dans SQL Editor, copie ceci :

```sql
-- Enable RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;

-- USERS: tout le monde peut lire, seul proprio peut update
CREATE POLICY "Users are viewable by authenticated users"
  ON users FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- GROUPS: membres peuvent lire, créateur peut update/delete
CREATE POLICY "Groups viewable by members"
  ON groups FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Authenticated users can create groups"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group creators can update their groups"
  ON groups FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Group creators can delete their groups"
  ON groups FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- GROUP_MEMBERS: membres peuvent lire, tout le monde peut insert (rejoindre)
CREATE POLICY "Group members viewable by group members"
  ON group_members FOR SELECT
  TO authenticated
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join groups"
  ON group_members FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave groups"
  ON group_members FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- WORKOUT_PROGRAMS: membres du groupe peuvent lire, tout le monde peut créer
CREATE POLICY "Workout programs viewable by group members"
  ON workout_programs FOR SELECT
  TO authenticated
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Authenticated users can create workout programs"
  ON workout_programs FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by AND
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Creators can update their programs"
  ON workout_programs FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Creators can delete their programs"
  ON workout_programs FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- MEAL_PLANS: même logique que workout_programs
CREATE POLICY "Meal plans viewable by group members"
  ON meal_plans FOR SELECT
  TO authenticated
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Authenticated users can create meal plans"
  ON meal_plans FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by AND
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Creators can update their meal plans"
  ON meal_plans FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Creators can delete their meal plans"
  ON meal_plans FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);
```

**Run** le script.

---

## 5. Trigger auto-création profil user

Quand user signup via auth, auto-créer ligne dans `users` :

```sql
-- Function pour créer profil user automatiquement
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger sur auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

**Run** le script.

---

## 6. Configuration Flutter

Dans ton app Flutter, ajoute les clés :

**Créer `lib/supabase_config.dart` :**

```dart
class SupabaseConfig {
  static const String url = 'https://TON_PROJECT_ID.supabase.co';
  static const String anonKey = 'eyJhbGc...TON_ANON_KEY';
}
```

**⚠️ Ne commit JAMAIS ces clés dans git public !**

Mieux : utilise des variables d'environnement ou `flutter_dotenv`.

---

## 7. Test rapide

Dans Supabase → Table Editor :
- Clique sur `users` → devrait être vide
- Va dans Authentication → Users → Create user (test@test.com)
- Retourne Table Editor → `users` → devrait avoir 1 ligne (auto-créée par trigger)

Si ✅ → setup complet !

---

## 🚀 Next Steps

1. **Configure Flutter app** → voir `SUPABASE_FLUTTER_SETUP.md`
2. **Teste auth** → signup/login
3. **Crée premier groupe**
4. **Développe UI**

---

## 📊 Monitoring

- Supabase Dashboard → Database → Usage
- Vérifie quotidiennement les premiers jours
- Free tier : 500 MB DB, 50k requêtes API/mois

Si tu approches des limites → optimise queries ou upgrade (mais peu probable au début).
