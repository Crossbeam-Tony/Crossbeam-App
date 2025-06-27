import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: 'https://bcpuiqajfwstleluitpa.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjcHVpcWFqZndzdGxlbHVpdHBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2OTc0NTUsImV4cCI6MjA2NjI3MzQ1NX0.0wZl54K3aLRlo3KoiTkM6XmnQk5hYUTsFV0vbDyDo3E',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
      debug: false,
    );
    print('  Supabase initialized');
  } catch (error) {
    print('  Error initializing Supabase: $error');
    rethrow;
  }
}

/*
SUPABASE CONFIGURATION GUIDE

This file documents the Supabase configuration for the Flutter app.

AUTHENTICATION SETUP:
1. Go to Supabase Dashboard > Authentication > URL Configuration
2. No redirect URLs needed for OTP-based verification

EMAIL TEMPLATE SETUP:
1. Go to Supabase Dashboard > Authentication > Email Templates
2. Edit the "Confirm signup" template
3. Update the template to show the OTP code instead of a link:
   Your verification code is: {{ .Token }}

OTP VERIFICATION:
- Users receive an email with a verification code
- They enter the code in the verify-code page
- No deep links or redirect URLs required

TROUBLESHOOTING:
- If verification codes don't work, check the email template configuration
- Ensure the OTP expiry time is set appropriately in Supabase dashboard
*/
