import 'package:flutter_dotenv/flutter_dotenv.dart';

// Environment variables
String get API_URL => dotenv.env['API_URL'] ?? "";
