import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'screens/login.dart';
import 'utils/styles.dart';
import 'screens/splash_screen.dart';

/// DEVELOPMENT ONLY! Custom HttpOverrides to bypass SSL certificate validation
/// This is needed because the backend may use a certificate not in the device's trust store
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Main entry point for the Becathlon Mobile App
///
/// This app provides:
/// - User authentication (login/register)
/// - Product browsing with search and filters
/// - Integration with Django backend API
void main() {
  // Bypass SSL certificate validation for development (non-web platforms only)
  // WARNING: Remove this in production!
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      // Provide CookieRequest for session-based authentication
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'Becathlon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: SplashScreen(),
      ),
    );
  }
}
