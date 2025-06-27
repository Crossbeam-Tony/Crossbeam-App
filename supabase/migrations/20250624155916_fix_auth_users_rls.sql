-- Add RLS policy to allow user signups on auth.users table
-- This policy allows INSERT operations for unauthenticated users (signups)
CREATE POLICY "Allow signups" ON auth.users
  FOR INSERT 
  TO public
  WITH CHECK (true);

-- Also add a policy to allow users to read their own data
CREATE POLICY "Users can view own user data" ON auth.users
  FOR SELECT
  TO public
  USING (auth.uid() = id); 