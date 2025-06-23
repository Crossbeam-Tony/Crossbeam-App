-- This script updates your existing 'projects' table to add all the necessary columns.
-- Copy and paste the entire content of this file into the Supabase SQL editor and run it.

ALTER TABLE public.projects
  ADD COLUMN IF NOT EXISTS category TEXT,
  ADD COLUMN IF NOT EXISTS location TEXT,
  ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'planning',
  ADD COLUMN IF NOT EXISTS progress REAL DEFAULT 0.0,
  ADD COLUMN IF NOT EXISTS due_date TIMESTAMP,
  ADD COLUMN IF NOT EXISTS build_tags TEXT[],
  ADD COLUMN IF NOT EXISTS members TEXT[],
  ADD COLUMN IF NOT EXISTS images_by_tag JSONB,
  ADD COLUMN IF NOT EXISTS comments JSONB,
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- This script updates your existing 'profiles' table to add all the missing columns.
-- Copy and paste the entire content of this file into the Supabase SQL editor and run it.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS name TEXT,
  ADD COLUMN IF NOT EXISTS realname TEXT,
  ADD COLUMN IF NOT EXISTS email TEXT,
  ADD COLUMN IF NOT EXISTS bio TEXT,
  ADD COLUMN IF NOT EXISTS location TEXT,
  ADD COLUMN IF NOT EXISTS stats JSONB,
  ADD COLUMN IF NOT EXISTS mutual_crews TEXT[],
  ADD COLUMN IF NOT EXISTS skills TEXT[]; 