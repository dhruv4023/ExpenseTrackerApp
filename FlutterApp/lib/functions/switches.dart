import 'package:flutter/material.dart';

void switches(int index, BuildContext context) {
  switch (index) {
    case 0:
      Navigator.of(context).pushReplacementNamed('/home');
      break;
    case 1:
      Navigator.of(context).pushReplacementNamed('/transactions');
      break;
    case 2:
      Navigator.of(context).pushReplacementNamed('/labels');
      break;
  }
}
