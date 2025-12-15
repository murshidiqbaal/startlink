import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/env.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: true,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
