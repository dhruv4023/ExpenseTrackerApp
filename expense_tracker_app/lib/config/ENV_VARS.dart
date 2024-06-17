import 'package:flutter_dotenv/flutter_dotenv.dart';

// Environment variables
String  get API_URL => dotenv.env['API_URL'] ?? "";
String  get REACT_APP_CLOUDINARY_IMG => dotenv.env['REACT_APP_CLOUDINARY_IMG'] ?? "";
