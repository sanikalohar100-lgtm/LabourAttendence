import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:labourattendence/app_lock_screen.dart';
import 'package:labourattendence/language_provider.dart';
import 'package:labourattendence/main_bottom_screen.dart';
import 'package:labourattendence/welcome_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox('users');
  await Hive.openBox('session');
  await Hive.openBox('labours');
  await Hive.openBox('attendance');
  await Hive.openBox('overtime');

  var sessionBox = Hive.box('session');
  bool isLogin = sessionBox.get("isLogin", defaultValue: false);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MyApp(isLogin: isLogin),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLogin;

  const MyApp({super.key, required this.isLogin});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final LocalAuthentication auth = LocalAuthentication();
  //
  // bool unlocked = false;



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Labour Attendance',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),

      locale: provider.locale,

      supportedLocales: const [
        Locale("en"),
        Locale("mr"),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: widget.isLogin
          ? const WelcomeScreen()
          : const LoginScreen(),
    );
  }
}