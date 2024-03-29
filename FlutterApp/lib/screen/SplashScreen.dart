import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 5 seconds and then navigate to the homepage
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset('assets/imgs/img.jpg'),
          ),
        ),
      ),
    );
  }
}
