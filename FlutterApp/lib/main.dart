import 'package:flutter/material.dart';
// import 'package:expense_tracker/screen/Login/loginPage.dart';
import 'package:expense_tracker/screen/splash_screen.dart';
import 'package:expense_tracker/screen/home/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Fix the super constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(), // Set your splash screen as the initial route
      debugShowCheckedModeBanner: false,
      routes: {
        '': (context) => const HomePage(), // Define your homepage route
        // '/auth': (context) => LoginPage(),
      },
    );
  }
}
