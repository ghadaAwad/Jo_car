import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/app_router.dart';
import 'core/config/app_colors.dart';
import 'app_theme.dart';
import 'core/services/secure_storage_service.dart';
import 'features/auth/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل ملف البيئة
  await dotenv.load(fileName: '.env', isOptional: true);

  // تهيئة التخزين الآمن وAuthProvider
  final storage = SecureStorageService();
  final authProvider = AuthProvider(storage);
  await authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => authProvider),
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
    final router = buildRouter(auth); // استخدمنا AppRouter هنا

    return MaterialApp.router(
      title: 'JoCar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
