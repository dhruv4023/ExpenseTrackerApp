import 'dart:typed_data';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _pincodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String errorMessage = "";
  XFile? _image;

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoginForm) {
        // Perform login
        String username = _usernameController.text;
        String password = _passwordController.text;

        Map<String, String> loginData = {
          'uid': username,
          'password': password,
        };

        String loginJsonData = jsonEncode(loginData);

        String loginApiUrl = API_URL + '/auth/login';

        try {
          final loginResponse = await http.post(
            Uri.parse(loginApiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: loginJsonData,
          );

          if (loginResponse.statusCode == 200) {
            Map<String, dynamic> loginResponseData =
                jsonDecode(loginResponse.body);
            String? token = loginResponseData['data']['token'];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('token', token!);

            // Navigate to home page or perform any other actions on successful login

            Navigator.of(context).pushReplacementNamed('');
          } else {
            Map<String, dynamic> loginResponseData =
                jsonDecode(loginResponse.body);
            setState(() {
              errorMessage = loginResponseData['message'];
            });
          }
        } catch (e) {
          print('Login Exception: $e');
        }
      } else {
        // Perform signup
        String username = _usernameController.text;
        String password = _passwordController.text;
        // String firstName = _firstNameController.text;
        // String lastName = _lastNameController.text;
        // String email = _emailController.text;
        String state = _stateController.text;
        // String city = _cityController.text;
        // String pincode = _pincodeController.text;
        // List<int>? imageBytes =
        //     _image != null ? await _image!.readAsBytes() : null;
        print(username);
        print(password);

        List<int> fileBytes = await _image!.readAsBytes();
        Uint8List uint8List = Uint8List.fromList(fileBytes);

        FormData formData = FormData.fromMap({
          'username': username,
          'password': password,
          // 'firstName': firstName,
          // 'lastName': lastName,
          // 'email': email,
          'location': {
            'state': state,
            //   'city': city,
            //   'pincode': pincode,
          },
          // 'about': 'nothing',
          "picPath": uint8List != null
              ? await MultipartFile.fromBytes(
                  uint8List,
                  filename: 'image.jpg',
                  contentType: MediaType('image', 'jpeg'),
                )
              : null
        });
        print(API_URL);
        String signupApiUrl = '$API_URL/auth/register';

        print(signupApiUrl);
        try {
          final signupResponse = await Dio().post(
            (signupApiUrl),
            data: (formData), // Encode signupData to JSON
          );

          if (signupResponse.statusCode == 200) {
            Map<String, dynamic> signupResponseData =
                jsonDecode(signupResponse.data);
            String? token = signupResponseData['data']['token'];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('token', token!);

            // Navigate to home page or perform any other actions on successful signup
          } else {
            Map<String, dynamic> signupResponseData =
                jsonDecode(signupResponse.data);
            setState(() {
              errorMessage = signupResponseData['message'];
            });
          }
        } catch (e) {
          print('Signup Exception: $e');
        }
      }
    }
  }

  bool _isLoginForm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                            'assets/imgs/user.jpg'), // Default image
                      ),
                    ),
                  ),
                  Text(_isLoginForm ? 'Login' : 'Signup',
                      style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                      ),
                      validator: (value) =>
                          _validateRequired(value, 'username'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (value) =>
                          _validateRequired(value, 'password'),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!_isLoginForm)
                    Column(
                      children: [
                        // Container(
                        //   constraints: BoxConstraints(maxWidth: 500),
                        //   child: TextFormField(
                        //     controller: _firstNameController,
                        //     decoration: InputDecoration(
                        //       labelText: 'First Name',
                        //     ),
                        //     validator: (value) =>
                        //         _validateRequired(value, 'first name'),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //   constraints: BoxConstraints(maxWidth: 500),
                        //   child: TextFormField(
                        //     controller: _lastNameController,
                        //     decoration: InputDecoration(
                        //       labelText: 'Last Name',
                        //     ),
                        //     validator: (value) =>
                        //         _validateRequired(value, 'last name'),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //   constraints: BoxConstraints(maxWidth: 500),
                        //   child: TextFormField(
                        //     controller: _emailController,
                        //     decoration: InputDecoration(
                        //       labelText: 'Email',
                        //     ),
                        //     validator: (value) =>
                        //         _validateRequired(value, 'email'),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //   constraints: BoxConstraints(maxWidth: 500),
                        //   child: TextFormField(
                        //     controller: _stateController,
                        //     decoration: InputDecoration(
                        //       labelText: 'State',
                        //     ),
                        //     validator: (value) =>
                        //         _validateRequired(value, 'state'),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //   constraints: BoxConstraints(maxWidth: 500),
                        //   child: TextFormField(
                        //     controller: _cityController,
                        //     decoration: InputDecoration(
                        //       labelText: 'City',
                        //     ),
                        //     validator: (value) =>
                        //         _validateRequired(value, 'city'),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //   constraints: BoxConstraints(maxWidth: 500),
                        //   child: TextFormField(
                        //     controller: _pincodeController,
                        //     decoration: InputDecoration(
                        //       labelText: 'Pincode',
                        //     ),
                        //     validator: (value) =>
                        //         _validateRequired(value, 'pincode'),
                        //   ),
                        // ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            XFile? pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              setState(() {
                                // Convert XFile to File
                                _image = XFile(pickedFile.path);
                              });
                            }
                          },
                          child: Text('Pick an image'),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isLoginForm ? 'Login' : 'Signup'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginForm = !_isLoginForm;
                        errorMessage = ""; // Clear error message on form toggle
                      });
                    },
                    child: Text(
                      _isLoginForm
                          ? 'not have account ? click here to Signup'
                          : 'already have an account! click here to Login',
                    ),
                  ),
                  SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
