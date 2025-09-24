import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/unauthorized_screen.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart'; // Import the new WelcomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://owcanqgrymdruzdrttfo.supabase.co',
    anonKey: 'sb_publishable_h4qjPODt0V22BAolM6R_ug_OrkKwQ6b',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          child: MaterialApp(
            title: 'QCVATION',
            theme: AppTheme.lightTheme,
            // Change the home screen to WelcomeScreen
            home: const WelcomeScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/unauthorized': (context) => const UnauthorizedScreen(),
            },
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          if (authProvider.isAuthorized) {
            return const HomeScreen();
          } else {
            return const UnauthorizedScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}