import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/super_admin/screens/super_admin_dashboard.dart';
import 'features/customer_admin/screens/customer_admin_dashboard.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: WaterMonitorApp()));
}

class WaterMonitorApp extends StatelessWidget {
  const WaterMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aqua Drops',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769AA)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/':              (_) => const SplashScreen(),
        '/login':         (_) => const LoginScreen(),
        '/super-admin':   (_) => const SuperAdminDashboard(),
        '/customer-admin':(_) => const CustomerAdminDashboard(),
        '/home':          (_) => const _PlaceholderScreen(title: 'My Tank'),
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1769AA),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(title,
          style: const TextStyle(fontSize: 20, color: Color(0xFF172B4D))),
      ),
    );
  }
}
