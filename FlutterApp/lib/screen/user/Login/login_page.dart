import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/widgets/alert_dialog.dart'; // Import config.dart

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
  bool _isLoading = false;

  Future<void> saveUserToSharedPreferences(Map<String, dynamic> user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', jsonEncode(user));
  }

  Future<void> saveTokenToSharedPreferences(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  Future<void> _pickImage() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _tmp_login() async {
    await saveTokenToSharedPreferences(
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTcyNDg3ODgsInVzZXJJZCI6IjY1Yjc1MTMwOGI2ODJjMWU4ZTMzYjZlYSIsInVzZXJuYW1lIjoiZGhydXY0MDIzIiwicm9sZSI6ImFkbWluIiwiaWF0IjoxNzE3MjMwNzg4fQ.uBm32FH6I4muKPHp10Rl1kIMg8CNt1nNLJ_v55xLPG8");
    await saveUserToSharedPreferences({
      "location": {"state": "Gujarat", "city": "Chikhli", "pincode": 396521},
      "_id": "65b751308b682c1e8e33b6ea",
      "firstName": "Dhruv",
      "lastName": "Patel",
      "username": "dhruv4023",
      "about": "nothing ",
      "email": "dhruv20345@gmail.com",
      "picPath": "Users/dhruv4023/profileImg",
      "impressions": 0,
      "createdAt": "2024-01-29T07:18:08.142Z",
      "updatedAt": "2024-04-17T07:25:52.455Z",
      "__v": 0,
      "role": "admin"
    });
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true; // Start loading indicator
      errorMessage = "";
    });
    try {
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

              await saveTokenToSharedPreferences(
                  loginResponseData['data']['token']);
              await saveUserToSharedPreferences(
                  loginResponseData['data']['user']);
              Navigator.of(context).pushReplacementNamed('/home');
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
          var signupApiUrl = Uri.parse('$API_URL/auth/register');

          String username = _usernameController.text;
          String password = _passwordController.text;
          String firstName = _firstNameController.text;
          String lastName = _lastNameController.text;
          String email = _emailController.text;
          String state = _stateController.text;
          String city = _cityController.text;
          String pincode = _pincodeController.text;

          var request = http.MultipartRequest('POST', signupApiUrl)
            ..fields['username'] = username
            ..fields['password'] = password
            ..fields['firstName'] = firstName
            ..fields['lastName'] = lastName
            ..fields['email'] = email
            ..fields['location.state'] = state
            ..fields['location.city'] = city
            ..fields['location.pincode'] = pincode;

          if (_image != null) {
            List<int> fileBytes = await _image!.readAsBytes();
            List<String> mimeTypeData = _image!.mimeType!.split('/');
            request.files.add(
              http.MultipartFile.fromBytes(
                'picPath',
                fileBytes,
                filename: 'upload.jpg',
                contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
              ),
            );
          }

          try {
            final signupResponse = await request.send();

            final responseString = await signupResponse.stream.bytesToString();

            if (signupResponse.statusCode == 200) {
              Map<String, dynamic> signupResponseData =
                  jsonDecode(responseString);

              showMyAlertDialog(context, signupResponseData["message"]);

              Navigator.of(context).pushReplacementNamed('');
            } else {
              Map<String, dynamic> signupResponseData =
                  jsonDecode(responseString);

              setState(() {
                errorMessage = signupResponseData['message'];
              });
            }
          } catch (e) {
            print('Signup Exception: $e');
          }
        }
      }
    } catch (e) {
      print('Submit Form Exception: $e');
    } finally {
      setState(() {
        _isLoading = false; // stop loading indicator
      });
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
                        child: _image != null
                            ? Image.network(
                                _image!.path,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
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
                      enabled: !_isLoading,
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
                      enabled: !_isLoading,
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
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              enabled: !_isLoading,
                              labelText: 'First Name',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'first name'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'last name'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'email'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _stateController,
                            decoration: InputDecoration(
                              labelText: 'State',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'state'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: 'City',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'city'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _pincodeController,
                            decoration: InputDecoration(
                              labelText: 'Pincode',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'pincode'),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _pickImage,
                          child: Text('Pick an image'),
                          style: ElevatedButton.styleFrom(
                            // Add style when button is disabled
                            textStyle: TextStyle(color: Colors.white),
                            backgroundColor: _isLoading
                                ? Colors.grey
                                : Colors.blue, // Change color when disabled
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: Text(_isLoginForm ? 'Login' : 'Signup'),
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(color: Colors.white),
                      backgroundColor: _isLoading
                          ? Colors.grey
                          : Colors.blue, // Change color when disabled
                    ),
                  ),

                  //  ----------------------------------------------------------------------------//
                  ElevatedButton(
                    onPressed: _isLoading ? null : _tmp_login,
                    child: Text('Tmp Login'),
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(color: Colors.white),
                      backgroundColor: _isLoading
                          ? Colors.grey
                          : Colors.blue, // Change color when disabled
                    ),
                  ),
                  //  ----------------------------------------------------------------------------//
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLoginForm = !_isLoginForm;
                              errorMessage =
                                  ""; // Clear error message on form toggle
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
                  if (_isLoading) CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
