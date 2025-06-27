-- This migration will help us check the table schemas
-- Run this and check the output in the Supabase dashboard

-- Create a temporary function to check schemas
CREATE OR REPLACE FUNCTION check_table_schemas()
RETURNS TABLE (
    table_schema text,
    table_name text,
    column_name text,
    data_type text,
    is_nullable text,
    has_default text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.table_schema::text,
        c.table_name::text,
        c.column_name::text,
        c.data_type::text,
        c.is_nullable::text,
        CASE WHEN c.column_default IS NOT NULL THEN 'YES' ELSE 'NO' END::text
    FROM information_schema.columns c
    WHERE c.table_schema IN ('auth', 'public')
      AND c.table_name IN ('users', 'profiles')
    ORDER BY c.table_schema, c.table_name, c.ordinal_position;
END;
$$ LANGUAGE plpgsql;

-- Call the function to see the schema
SELECT * FROM check_table_schemas();

-- Check constraints
SELECT 
    tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema IN ('auth', 'public')
  AND tc.table_name IN ('users', 'profiles')
ORDER BY tc.table_schema, tc.table_name;

-- Clean up
DROP FUNCTION IF EXISTS check_table_schemas(); 