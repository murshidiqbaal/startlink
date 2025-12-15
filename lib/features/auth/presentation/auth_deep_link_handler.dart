import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDeepLinkHandler extends StatefulWidget {
  final Widget child;
  const AuthDeepLinkHandler({super.key, required this.child});

  @override
  State<AuthDeepLinkHandler> createState() => _AuthDeepLinkHandlerState();
}

class _AuthDeepLinkHandlerState extends State<AuthDeepLinkHandler> {
  @override
  void initState() {
    super.initState();
    _handleDeepLink();
  }

  Future<void> _handleDeepLink() async {
    try {
      // Check for current current session URL manually if needed
      // Note: SupabaseFlutter usually handles this, but the user requested explicit handling
      final uri = Uri.base;
      if (uri.toString().contains('access_token') &&
          uri.toString().contains('refresh_token')) {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      }
    } catch (e) {
      // Ignore errors for invalid URIs or if already handled
      debugPrint('Deep link handling error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
