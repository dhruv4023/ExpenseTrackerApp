import 'package:flutter/material.dart';

  void switches(int index,BuildContext context) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/labels');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/labels');
        break;
    }
  }