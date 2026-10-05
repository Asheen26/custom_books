import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/apptheme/theme_controller.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/splash/views/splash_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await AuthService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const SplashPage(),
          builder: (context, child) {
            Dimensions.init(context);
            final mediaQuery = MediaQuery.of(context);
            // Clamp text scale: guard against min > max which crashes the
            // Flutter date picker (_ClampedTextScaler assertion).
            const double minScale = 1.0;
            const double maxScale = 1.3;
            final double currentScale = mediaQuery.textScaler.scale(1.0);
            final double clampedScale = currentScale.clamp(minScale, maxScale);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(clampedScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
