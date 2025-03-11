import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/ai_chat_screen.dart';
import 'package:myapp/crowd_status_screen.dart';
import 'package:myapp/exhibits_screen.dart';
import 'package:myapp/home_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/signup_screen.dart';
import 'package:myapp/splash_screen.dart';
import 'package:myapp/tour_planner_screen.dart';
import 'package:myapp/navigation_screen.dart';
import 'package:myapp/profile_screen.dart'; // Import the real ProfileScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('users');
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Museum Guide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E3192),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/tours': (context) => const TourPlannerScreen(),
        '/explore': (context) => const ExhibitsScreen(),
        '/3dmap': (context) => const NavigationScreen(),
        '/profile': (context) => const ProfileScreen(), // Use the new ProfileScreen
        '/ai_chat': (context) => const ChatScreen(),
        '/crowd_status': (context) => const CrowdStatusScreen(),
      },
    );
  }
}