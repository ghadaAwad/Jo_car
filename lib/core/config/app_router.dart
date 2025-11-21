import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/views/forget_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/otp_verification_view.dart';
import '../../features/auth/views/profile.dart';
import '../../features/auth/views/edit_profile_view.dart';
import '../../features/auth/views/help_center_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../models/booking.dart';
import '../../models/car.dart';
import '../../views/home/details_page.dart';
import '../../views/home/home_page.dart';
import '../../views/provider/add_car_view.dart';
import '../../views/provider/edit_car_view.dart';
import '../../views/provider/provider-dashboard.dart';

import '../../views/booking/booking_page.dart';
import '../../views/booking/booking_details_page.dart';
import '../../views/booking/booking_success_page.dart';
import '../../views/booking/user_booking_page.dart';
import '../../views/splash/car_view.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/booking_provider.dart';
import '../../views/provider/provider_bookings_screen.dart';
import '../../views/provider/car_bookings_details_screen.dart';
import '../../views/provider/provider_cars_view.dart';

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,

    redirect: (context, state) {
      if (state.matchedLocation == '/splash') return null;

      if (!auth.isInitialized) return '/splash';

      final loggedIn = auth.isAuthenticated;

      final isAuth =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forget') ||
          state.matchedLocation.startsWith('/otp');

      if (!loggedIn && !isAuth) return '/login';

      if (loggedIn && isAuth) return '/home';

      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashView()),

      GoRoute(path: '/login', builder: (_, __) => const LoginView()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterView()),
      GoRoute(path: '/forget', builder: (_, __) => const ForgetPasswordView()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpVerificationView()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileView()),

      GoRoute(
        path: '/profile/settings',
        builder: (_, __) => const EditProfileView(),
      ),

      GoRoute(path: '/help-center', builder: (_, __) => const HelpCenterView()),
      GoRoute(path: '/my-bookings', builder: (_, __) => const MyBookingsPage()),

      GoRoute(path: '/home', builder: (_, __) => const HomePage()),

      GoRoute(
        path: '/details',
        builder: (context, state) {
          final car = state.extra;
          if (car == null || car is! Car) {
            return const Scaffold(body: Center(child: Text("Car not found")));
          }
          return DetailsPage(car: car);
        },
      ),

      GoRoute(
        path: '/provider-dashboard',
        builder: (_, __) => const ProviderDashboardView(),
        routes: [
          GoRoute(path: 'add-car', builder: (_, __) => const AddCarView()),
          GoRoute(
            path: 'edit-car',
            builder: (context, state) {
              final car = state.extra as Car;
              return EditCarView(car: car);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final car = state.extra;
          if (car == null || car is! Car) {
            return const Scaffold(
              body: Center(child: Text("Car data is missing")),
            );
          }
          return BookingPage(car: car);
        },
      ),

      GoRoute(
        path: '/booking-details',
        builder: (context, state) {
          final booking = state.extra;
          if (booking == null || booking is! Booking) {
            return const Scaffold(
              body: Center(child: Text("Booking not found")),
            );
          }
          return BookingDetailsPage(booking: booking);
        },
      ),

      GoRoute(
        path: '/booking-success',
        builder: (context, state) {
          final booking = state.extra;
          if (booking == null || booking is! Booking) {
            return const Scaffold(
              body: Center(child: Text("Booking data missing!")),
            );
          }
          return BookingSuccessPage(booking: booking);
        },
      ),

      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsPage(),
      ),

      // --------------------------------------------------------------------
      // 🔥 الذكاء — route يحدد المستخدم User أو Provider
      // --------------------------------------------------------------------
      GoRoute(
        path: '/booking-center',
        builder: (context, state) {
          final auth = Provider.of<AuthProvider>(context, listen: false);

          if (!auth.isAuthenticated || auth.user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final type = auth.user!["type"];

          if (type == "Provider") {
            return const ProviderBookingsPage();
          } else {
            return const MyBookingsPage();
          }
        },
      ),

      GoRoute(
        path: '/provider-bookings',
        builder: (context, state) => const ProviderBookingsPage(),
      ),

      GoRoute(
        path: '/provider-booking-details',
        builder: (context, state) {
          final data = state.extra;

          if (data == null || data is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(child: Text("Details data missing")),
            );
          }

          return CarBookingsDetailsScreen(
            car: data["car"],
            historyBookings: data["history"],
            currentBooking: data["current"],
          );
        },
      ),

      GoRoute(
        path: '/provider-cars',
        builder: (context, state) {
          final providerData = state.extra as Map<String, dynamic>;
          return ProviderCarsView(
            providerId: providerData["id"],
            providerName: providerData["name"],
            providerCity: providerData["city"],
          );
        },
      ),
    ],
  );
}
