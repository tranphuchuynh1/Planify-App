import 'package:flutter/material.dart';
import 'package:hoctapflutter/core/services/supabase_service.dart';
import 'package:hoctapflutter/ui/home/main_page.dart';
import 'package:hoctapflutter/ui/splash/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({super.key});

  @override
  State<AuthenticationGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthenticationGate> {
  @override
  void initState() {
    super.initState();

    // listion thay đổi trạng thái authentication
    SupabaseService.authStateChanges.listen((AuthState data) {
      if (mounted) {
        setState(() {
          // Widget sẽ tự động rebuild khi auth state thay đổi
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái đăng nhập
    if (SupabaseService.isLoggedIn) {
      // Đã đăng nhập -> Chuyển đến MainPage luôn
      return const MainPage();
    } else {
      // Chưa đăng nhập -> Hiển thị SplashScreen (tức là chưa đăng nhập thì đá ra lại login)
      return const SplashScreen();
    }
  }
}