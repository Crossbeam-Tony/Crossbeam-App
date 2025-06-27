-- Temporarily disable the trigger to test user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users; 