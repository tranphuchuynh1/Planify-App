import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hoctapflutter/ui/home/main_page.dart';
import 'package:hoctapflutter/ui/login/login_page.dart';
import 'package:hoctapflutter/ui/onboarding/onboarding_page_view.dart';
import 'package:hoctapflutter/ui/splash/splash.dart';
import 'package:hoctapflutter/ui/welcome/welcome_page.dart';

import 'core/authentications/authentication_gate.dart';
import 'core/services/supabase_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await EasyLocalization.ensureInitialized();
  // Khởi tạo Supabase
  await SupabaseService.initialize();

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale("vi"),
        Locale("en")
      ],
      path: "assets/translations",
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      home: const AuthenticationGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
