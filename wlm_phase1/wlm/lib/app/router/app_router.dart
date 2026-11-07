import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';

// ── Route path constants ──────────────────────────────────────────────────────
abstract final class AppRoutes {
  // Auth
  static const String splash        = '/';
  static const String login         = '/login';

  // Super Admin
  static const String saDashboard   = '/super-admin';
  static const String saCustomers   = '/super-admin/customers';
  static const String saCustomerDetail = '/super-admin/customers/:id';
  static const String saDevices     = '/super-admin/devices';
  static const String saDeviceDetail= '/super-admin/devices/:id';
  static const String saUsers       = '/super-admin/users';
  static const String saAlerts      = '/super-admin/alerts';
  static const String saSettings    = '/super-admin/settings';

  // Customer Admin
  static const String caHome        = '/customer-admin';
  static const String caDevices     = '/customer-admin/devices';
  static const String caDeviceDetail= '/customer-admin/devices/:id';
  static const String caUsers       = '/customer-admin/users';
  static const String caAlerts      = '/customer-admin/alerts';
  static const String caSettings    = '/customer-admin/settings';

  // Customer User
  static const String userHome      = '/home';
  static const String userHistory   = '/home/history';
  static const String userAlerts    = '/home/alerts';
  static const String userSettings  = '/home/settings';
}

// ── Auth state provider — replace with actual Firebase auth stream ────────────
// Placeholder: null = loading, empty string = logged out, uid = logged in
final authStateProvider = StateProvider<String?>((ref) => null);

// Placeholder user role — replace with actual profile fetch
final userRoleProvider = StateProvider<UserRole?>((ref) => null);

// ── Router provider ───────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRole  = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      final isLoading     = authState == null;
      final isLoggedOut   = authState == '';
      final isOnSplash    = state.matchedLocation == AppRoutes.splash;
      final isOnLogin     = state.matchedLocation == AppRoutes.login;

      // Still loading Firebase auth — stay on splash
      if (isLoading) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      // Not authenticated
      if (isLoggedOut) {
        return isOnLogin ? null : AppRoutes.login;
      }

      // Authenticated — route to correct role dashboard
      if (isOnSplash || isOnLogin) {
        return _homeForRole(userRole);
      }

      // Guard: prevent wrong role from accessing another role's routes
      if (!_isAllowedRoute(state.matchedLocation, userRole)) {
        return _homeForRole(userRole);
      }

      return null;
    },

    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const _PlaceholderScreen(label: 'Splash'),
      ),

      // ── Login ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(label: 'Login'),
      ),

      // ── Super Admin Shell ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            _PlaceholderShell(label: 'Super Admin', child: child),
        routes: [
          GoRoute(
            path: AppRoutes.saDashboard,
            name: 'saDashboard',
            builder: (_, __) => const _PlaceholderScreen(label: 'SA Dashboard'),
          ),
          GoRoute(
            path: AppRoutes.saCustomers,
            name: 'saCustomers',
            builder: (_, __) => const _PlaceholderScreen(label: 'Customers'),
            routes: [
              GoRoute(
                path: ':id',
                name: 'saCustomerDetail',
                builder: (_, s) => _PlaceholderScreen(
                  label: 'Customer ${s.pathParameters['id']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.saDevices,
            name: 'saDevices',
            builder: (_, __) => const _PlaceholderScreen(label: 'All Devices'),
            routes: [
              GoRoute(
                path: ':id',
                name: 'saDeviceDetail',
                builder: (_, s) => _PlaceholderScreen(
                  label: 'Device ${s.pathParameters['id']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.saUsers,
            name: 'saUsers',
            builder: (_, __) => const _PlaceholderScreen(label: 'All Users'),
          ),
          GoRoute(
            path: AppRoutes.saAlerts,
            name: 'saAlerts',
            builder: (_, __) => const _PlaceholderScreen(label: 'All Alerts'),
          ),
          GoRoute(
            path: AppRoutes.saSettings,
            name: 'saSettings',
            builder: (_, __) => const _PlaceholderScreen(label: 'SA Settings'),
          ),
        ],
      ),

      // ── Customer Admin Shell ───────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            _PlaceholderShell(label: 'Customer Admin', child: child),
        routes: [
          GoRoute(
            path: AppRoutes.caHome,
            name: 'caHome',
            builder: (_, __) => const _PlaceholderScreen(label: 'CA Dashboard'),
          ),
          GoRoute(
            path: AppRoutes.caDevices,
            name: 'caDevices',
            builder: (_, __) => const _PlaceholderScreen(label: 'My Devices'),
            routes: [
              GoRoute(
                path: ':id',
                name: 'caDeviceDetail',
                builder: (_, s) => _PlaceholderScreen(
                  label: 'Device ${s.pathParameters['id']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.caUsers,
            name: 'caUsers',
            builder: (_, __) => const _PlaceholderScreen(label: 'My Users'),
          ),
          GoRoute(
            path: AppRoutes.caAlerts,
            name: 'caAlerts',
            builder: (_, __) => const _PlaceholderScreen(label: 'Alerts'),
          ),
          GoRoute(
            path: AppRoutes.caSettings,
            name: 'caSettings',
            builder: (_, __) => const _PlaceholderScreen(label: 'CA Settings'),
          ),
        ],
      ),

      // ── Customer User Shell ────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            _PlaceholderShell(label: 'User', child: child),
        routes: [
          GoRoute(
            path: AppRoutes.userHome,
            name: 'userHome',
            builder: (_, __) => const _PlaceholderScreen(label: 'My Tank'),
          ),
          GoRoute(
            path: AppRoutes.userHistory,
            name: 'userHistory',
            builder: (_, __) => const _PlaceholderScreen(label: 'History'),
          ),
          GoRoute(
            path: AppRoutes.userAlerts,
            name: 'userAlerts',
            builder: (_, __) => const _PlaceholderScreen(label: 'Alerts'),
          ),
          GoRoute(
            path: AppRoutes.userSettings,
            name: 'userSettings',
            builder: (_, __) => const _PlaceholderScreen(label: 'Settings'),
          ),
        ],
      ),
    ],
  );
});

// ── Helpers ───────────────────────────────────────────────────────────────────

String? _homeForRole(UserRole? role) {
  return switch (role) {
    UserRole.superAdmin    => AppRoutes.saDashboard,
    UserRole.customerAdmin => AppRoutes.caHome,
    UserRole.customerUser  => AppRoutes.userHome,
    null                   => AppRoutes.login,
  };
}

bool _isAllowedRoute(String location, UserRole? role) {
  return switch (role) {
    UserRole.superAdmin    => location.startsWith('/super-admin'),
    UserRole.customerAdmin => location.startsWith('/customer-admin'),
    UserRole.customerUser  => location.startsWith('/home'),
    null                   => false,
  };
}

// ── Placeholder widgets — replaced in Phase 2+ ───────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(label, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

class _PlaceholderShell extends StatelessWidget {
  const _PlaceholderShell({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
