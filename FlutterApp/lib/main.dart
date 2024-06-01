import 'package:flutter/material.dart';
import 'package:expense_tracker/screen/splash_screen.dart';
import 'package:expense_tracker/screen/home/home_page.dart';
import 'package:expense_tracker/screen/user/profile_page.dart';
import 'package:expense_tracker/screen/label/label_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/labels': (context) => LabelsPage(),
        // Add more routes here if needed
      },
    );
  }
}
