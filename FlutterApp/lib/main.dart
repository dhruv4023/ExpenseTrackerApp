import 'package:expense_tracker/screen/auth_user/Login/login_page.dart';
import 'package:expense_tracker/screen/transactions/transactions.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/screen/splash_screen.dart';
import 'package:expense_tracker/screen/home/home_page.dart';
import 'package:expense_tracker/screen/auth_user/profile_page.dart';
import 'package:expense_tracker/screen/label/label_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import "services/theme_notifier.dart";

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(false), // Start with light mode
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      home: SplashScreen(),
      title: 'Expense Tracker',
      theme: themeNotifier.currentTheme,
      initialRoute: '/home',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/transactions': (context) => const TransactionsPage(),
        '/labels': (context) => const LabelsPage(),
        '/wait': (context) => const SplashScreen(),
      },
    );
  }
}
