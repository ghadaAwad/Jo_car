import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../models/car.dart';
import 'package:flutter/material.dart';

import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/forget_password_view.dart';
import '../../features/auth/views/otp_verification_view.dart';
import '../../features/auth/views/profile.dart';
import '../../views/home/home_page.dart';
import '../../views/home/details_page.dart';
import '../../views/splash/car_view.dart';
import '../../views/provider/provider-dashboard.dart';
import '../../views/provider/add_car_view.dart';

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/car', // first
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forget') ||
          state.matchedLocation.startsWith('/otp');

      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/car', builder: (_, __) => const CarView()),
      GoRoute(path: '/login', builder: (_, __) => const LoginView()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterView()),
      GoRoute(path: '/forget', builder: (_, __) => const ForgetPasswordView()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpVerificationView()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileView()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardView()),
      GoRoute(path: '/add-car', builder: (_, __) => const AddCarView()),

      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(
        path: '/details',
        builder: (context, state) {
          final extra = state.extra;

          // ✅ حماية من null أو نوع خاطئ
          if (extra == null || extra is! Car) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Car data not found ❌',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          // ✅ استرجاع الصفحة بشكل طبيعي
          return DetailsPage(car: extra);
        },
      ),
    ],
  );
}
