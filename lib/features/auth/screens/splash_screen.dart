import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../repositories/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      // Await the first emission so we don't hit the loading state
      final user = await FirebaseAuth.instance.authStateChanges().first;

      if (user == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      final profile = await repo.getUserProfile(user.uid);
      if (!mounted) return;

      final role = profile?['role'] as String? ?? 'customer_user';
      ref.read(userRoleProvider.notifier).state = role;
      ref.read(userDisplayNameProvider.notifier).state =
          profile?['name'] as String?;

      final route = switch (role) {
        'super_admin'    => '/super-admin',
        'customer_admin' => '/customer-admin',
        _                => '/home',
      };
      if (mounted) Navigator.pushReplacementNamed(context, route);
    } catch (_) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F8FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 80, color: Color(0xFF1769AA)),
            SizedBox(height: 20),
            Text(
              'Aqua Drops',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Smart Water. Smart Life.',
              style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Color(0xFF1769AA)),
          ],
        ),
      ),
    );
  }
}
