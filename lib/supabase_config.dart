import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'https://lllteskvfsnffrqwgigx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsbHRlc2t2ZnNuZmZycXdnaWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2MDA5MTAsImV4cCI6MjA2NjE3NjkxMH0.wMwszC5b2jtM55sqkgCwv9aZciilqX2FqKlxt1S8FMg',
  );
}
