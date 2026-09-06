import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/welcome_screen.dart';

const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const SimbiosisApp());
}

class SimbiosisApp extends StatelessWidget {
  const SimbiosisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simbiosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0F382C),
        scaffoldBackgroundColor: const Color(0xFFCBE3E7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F382C),
          primary: const Color(0xFF0F382C),
          secondary: const Color(0xFF1CB026),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
