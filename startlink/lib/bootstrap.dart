import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:startlink/core/services/supabase_client.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox(
    'settings',
  ); // Box for persistent settings like Active Role

  runApp(await builder());
}
