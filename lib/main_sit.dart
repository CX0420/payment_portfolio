// lib/main_sit.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:payment_portfolio/pages/home_page.dart';
import 'package:payment_portfolio/pages/login_page.dart';
import 'package:payment_portfolio/pages/main_page.dart';
import 'package:payment_portfolio/pages/sales_history.dart';
import 'package:payment_portfolio/pages/settings.dart';
import 'package:payment_portfolio/pages/amount_page.dart';
import 'config.dart';

void main() async {
  Config.setEnvironment(Environment.sit);
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open the necessary boxes
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('youseBox'); // Replace with your actual box name

  // Set system UI mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Payment Portfolio (SIT)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 68, 153, 249), // your blue
        ),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/',
          page: () => const MainPage(child: HomePage()),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/sales_history',
          page: () => const MainPage(child: SalesHistory()),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/settings',
          page: () => const MainPage(child: Settings()),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/amount',
          page: () => const MainPage(child: Amount(paymentType: '')),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/login',
          page: () => const MainPage(child: Login()),
          transition: Transition.fadeIn,
        )
      ],
      defaultTransition: Transition.fadeIn,
    );
  }
}
