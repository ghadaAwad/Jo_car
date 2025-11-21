import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/app_router.dart';
import 'app_theme.dart';
import 'core/services/secure_storage_service.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/car_provider.dart';
import 'features/auth/providers/booking_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// WebView imports
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------
  // 🔥 Fix WebView (Android + iOS ONLY)
  // --------------------------------------------------------
  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }
  // --------------------------------------------------------

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: 'assets/.env');

  final storage = SecureStorageService();
  final authProvider = AuthProvider(storage);
  await authProvider.restoreSession();

  final messaging = FirebaseMessaging.instance;

  if (!kIsWeb) {
    await messaging.requestPermission();
  }

  final fcmToken = await messaging.getToken();
  print("User FCM Token: $fcmToken");

  final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
  if (currentUser != null && fcmToken != null) {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .update({"fcmToken": fcmToken});
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => authProvider),
        ChangeNotifierProvider<CarProvider>(create: (_) => CarProvider()),
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),
      ],
      child: const JoCarApp(),
    ),
  );
}

class JoCarApp extends StatelessWidget {
  const JoCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final router = buildRouter(auth);

    return MaterialApp.router(
      title: 'JoCar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
