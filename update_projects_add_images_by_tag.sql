-- 📦 Ensure Supabase Storage bucket 'project-images' exists (skip if already done)
-- Go to your Supabase Dashboard → Storage → Create bucket named:
--  👉 `project-images` (public or authenticated, your call)

-- 🧱 Update Supabase Schema (run via SQL editor once)
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS images_by_tag JSONB; 