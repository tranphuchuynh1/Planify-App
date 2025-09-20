import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://jmapbgzdrnnbsleyzcto.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImptYXBiZ3pkcm5uYnNsZXl6Y3RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4NDc0MTgsImV4cCI6MjA3MzQyMzQxOH0.A4Bw7Bl1X2SDvlwI0AvDRHxtE-GqoMfHoWasENZeZ3c';

  static late Supabase _instance;
  static SupabaseClient get client => _instance.client;

  static Future initialize() async {
    _instance = await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static Future signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  static Future signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }


// code service signInWithGoogle for supabase
  static Future signInWithGoogle({
    required String accessToken,
    required String idToken,
  }) async {
    try {
      final response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  static Future signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userEmail => currentUser?.email;

  static String? get userName {
    final user = currentUser;
    if (user != null) {
      if (user.userMetadata?['full_name'] != null) {
        return user.userMetadata!['full_name'];
      }
      return user.email?.split('@')[0];
    }
    return null;
  }

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}