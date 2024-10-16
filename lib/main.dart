import 'package:envfriendly/services/push_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'screens/login_page.dart';
import 'language_notifier.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Conditional import for web
import 'utils/web_url_strategy.dart' if (dart.library.io) 'utils/mobile_url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use the conditionally imported function
  configureApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeNotifier()),
              ChangeNotifierProvider(create: (_) => LanguageNotifier()),
            ],
            child: Consumer2<ThemeNotifier, LanguageNotifier>(
              builder: (context, themeNotifier, languageNotifier, child) {
                return MaterialApp(
                  title: 'Rbuy - Refill as a Service',
                  theme: ThemeData(
                    primarySwatch: Colors.deepPurple,
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: Colors.white,
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: Colors.deepPurple),
                    ),
                  ),
                  darkTheme: ThemeData(
                    primarySwatch: Colors.deepPurple,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Colors.grey[900],
                    appBarTheme: AppBarTheme(
                      backgroundColor: Colors.grey[900],
                      iconTheme: const IconThemeData(color: Colors.white),
                    ),
                  ),
                  themeMode: themeNotifier.themeMode,
                  home: const LoginPage(),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en', ''),
                    Locale('kn', ''),
                  ],
                  locale: languageNotifier.locale,
                );
              },
            ),
          );
        }
        // While waiting for initialization, show loading screen
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDFyd958Ya6qK3SGrLaacJQeoAd4-dk7yU",
          authDomain: "envfriendly.firebaseapp.com",
          projectId: "envfriendly",
          storageBucket: "envfriendly.appspot.com",
          messagingSenderId: "34450201762",
          appId: "1:34450201762:web:dba2dcbb321d6c39decbfb",
        ),
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    PushNotificationService notificationService = PushNotificationService();
    await notificationService.initialize();
  }
}