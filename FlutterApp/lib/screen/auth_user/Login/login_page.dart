import 'dart:async';
import 'dart:convert';
import 'package:expense_tracker/constants/colors.dart';
import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/widgets/alert_dialog.dart'; // Import config.dart
import 'package:expense_tracker/screen/auth_user/Login/forgot_password.dart'; // Import config.dart
import 'package:expense_tracker/functions/show_toast.dart'; // Import config.dart

class LoginPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  LoginPage({this.user});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final int LOGIN = 0, SIGNUP = 1, UPDATE = 2;
  int _authForm = 0; //
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";
  XFile? _image;
  bool _isLoading = false;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _pincodeController = TextEditingController();

  String? _imagPath;

  @override
  void initState() {
    super.initState();
    _checkOpenForm();
    _imagPath = widget.user?["picPath"];
    _usernameController = TextEditingController(text: widget.user?["username"]);
    _firstNameController =
        TextEditingController(text: widget.user?["firstName"]);
    _lastNameController = TextEditingController(text: widget.user?["lastName"]);
    _aboutController = TextEditingController(text: widget.user?["about"]);
    _emailController = TextEditingController(text: widget.user?["email"]);
    _cityController =
        TextEditingController(text: widget.user?["location"]["city"]);
    _stateController =
        TextEditingController(text: widget.user?["location"]["state"]);
    _pincodeController = TextEditingController(
        text: widget.user?["location"]["pincode"].toString());
  }

  Future<void> _checkOpenForm() async {
    String token = await retriveToken();
    if (token.isNotEmpty) {
      String? userJson = await retriveUserData();
      if (userJson != null) {
        setState(() {
          _authForm = UPDATE;
        });
      }
    }
  }

  Future<void> saveUserToSharedPreferences(Map<String, dynamic> user) async {
    await saveUser(user);
  }

  Future<void> saveTokenToSharedPreferences(String token) async {
    await saveToken(token);
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
    print(API_URL);
    if (API_URL.contains("localhost")) {
      setState(() {
        _isLoading = true; // Start loading indicator
        errorMessage = "";
      });
      try {
        final loginResponse = await http.post(
          Uri.parse('$API_URL/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'uid': "dhruv40123",
            'password': "123Tes",
            "unlimitedTokenTime": true
          }),
        );

        if (loginResponse.statusCode == 200) {
          Map<String, dynamic> loginResponseData =
              jsonDecode(loginResponse.body);

          await saveTokenToSharedPreferences(
              loginResponseData['data']['token']);
          await saveUserToSharedPreferences(loginResponseData['data']['user']);

          Navigator.of(context).pushReplacementNamed('/wait');
        } else {
          Map<String, dynamic> loginResponseData =
              jsonDecode(loginResponse.body);
          setState(() {
            errorMessage = loginResponseData['message'];
          });
        }
      } catch (e) {
        print('Login Exception: $e');
        showToast('Login Exception: $e error!!!!!');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // stop loading indicator
          });
        }
      }
    }
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPassword()),
    );
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true; // Start loading indicator
      errorMessage = "";
    });
    try {
      if (_formKey.currentState!.validate()) {
        if (_authForm == LOGIN) {
          // Perform login
          String username = _usernameController.text;
          String password = _passwordController.text;

          String loginApiUrl = '$API_URL/auth/login';

          try {
            final loginResponse = await http.post(
              Uri.parse(loginApiUrl),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                'uid': username,
                'password': password,
                "unlimitedTokenTime": true
              }),
            );

            if (loginResponse.statusCode == 200) {
              Map<String, dynamic> loginResponseData =
                  jsonDecode(loginResponse.body);

              await saveTokenToSharedPreferences(
                  loginResponseData['data']['token']);
              await saveUserToSharedPreferences(
                  loginResponseData['data']['user']);
              Navigator.of(context).pushReplacementNamed('/wait');
            } else {
              Map<String, dynamic> loginResponseData =
                  jsonDecode(loginResponse.body);
              setState(() {
                errorMessage = loginResponseData['message'];
              });
            }
          } catch (e) {
            print(e);
            showToast('Login Exception: $e');
          }
        } else {
          // Perform signup

          String username = _usernameController.text;
          String password = _passwordController.text;
          String firstName = _firstNameController.text;
          String lastName = _lastNameController.text;
          String email = _emailController.text;
          String state = _stateController.text;
          String about = _aboutController.text;
          String city = _cityController.text;
          String pincode = _pincodeController.text;

          if (_authForm == SIGNUP) {
            var signupApiUrl = Uri.parse('$API_URL/auth/register');
            var request = http.MultipartRequest('POST', signupApiUrl)
              ..fields['username'] = username
              ..fields['password'] = password
              ..fields['firstName'] = firstName
              ..fields['lastName'] = lastName
              ..fields['email'] = email
              ..fields['about'] = about
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

              final responseString =
                  await signupResponse.stream.bytesToString();

              if (signupResponse.statusCode == 200) {
                Map<String, dynamic> signupResponseData =
                    jsonDecode(responseString);

                showMyAlertDialog(context, signupResponseData["message"]);

                Navigator.of(context).pushReplacementNamed('/home');
              } else {
                Map<String, dynamic> signupResponseData =
                    jsonDecode(responseString);

                setState(() {
                  errorMessage = signupResponseData['message'];
                });
              }
            } catch (e) {
              showToast('Signup Exception: $e');
            }
          } else if (_authForm == UPDATE) {
            String userToken = await retriveToken();
            var updateApiUrl = Uri.parse('$API_URL/user/update/');
            var request = http.MultipartRequest('PUT', updateApiUrl)
              ..fields['firstName'] = firstName
              ..fields['lastName'] = lastName
              ..fields['email'] = email
              ..fields['about'] = about
              ..fields['location.state'] = state
              ..fields['location.city'] = city
              ..fields['location.pincode'] = pincode
              ..headers['Authorization'] = userToken;

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
              final updateResponse = await request.send();

              final responseString =
                  await updateResponse.stream.bytesToString();

              if (updateResponse.statusCode == 200) {
                Map<String, dynamic> updateResponseData =
                    jsonDecode(responseString);

                showMyAlertDialog(context, updateResponseData["message"]);

                await saveUserToSharedPreferences(
                    updateResponseData['data']['user']);
                Navigator.of(context).pushReplacementNamed('/profile');
              } else {
                Map<String, dynamic> updateResponseData =
                    jsonDecode(responseString);

                setState(() {
                  errorMessage = updateResponseData['message'];
                });
              }
            } catch (e) {
              showToast('UPDATE Exception: $e');
            }
          }
        }
      }
    } catch (e) {
      showToast('Submit Form Exception: $e');
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false; // stop loading indicator
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _authForm == UPDATE ? AppBar() : null,
      body:_loginContent());
  }
 
  Widget _loginContent() { 
    return  Center(
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
                            : _imagPath != null
                                ? Image.network(
                                    '$REACT_APP_CLOUDINARY_IMG/$_imagPath')
                                : Image.asset(
                                    'assets/imgs/user.jpg'), // Default image
                      ),
                    ),
                  ),
                  Text(
                      _authForm == LOGIN
                          ? 'Login'
                          : _authForm == SIGNUP
                              ? 'Signup'
                              : "Update Details",
                      style: const TextStyle(fontSize: 24)),

                  const SizedBox(height: 20),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: TextFormField(
                      controller: _usernameController,
                      enabled: !_isLoading && UPDATE != _authForm,
                      decoration: InputDecoration(
                        labelText:
                            _authForm != LOGIN ? 'Username' : 'Username/Email',
                      ),
                      validator: (value) =>
                          _validateRequired(value, 'username'),
                    ),
                  ),

                  const SizedBox(height: 10),
                  if (_authForm != UPDATE)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (value) =>
                            _validateRequired(value, 'password'),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (LOGIN != _authForm)
                    Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            controller: _firstNameController,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'first name'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'last name'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading && UPDATE != _authForm,
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'email'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _aboutController,
                            decoration: const InputDecoration(
                              labelText: 'About',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'about'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'state'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'city'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: _pincodeController,
                            decoration: const InputDecoration(
                              labelText: 'Pincode',
                            ),
                            validator: (value) =>
                                _validateRequired(value, 'pincode'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _pickImage,
                          style: ElevatedButton.styleFrom(
                            // Add style when button is disabled
                            textStyle: const TextStyle(color: tdBGColor),
                            backgroundColor: _isLoading
                                ? tdGrey
                                : tdBlue, // Change color when disabled
                          ),
                          child: const Text('Pick an image'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(color: tdBGColor),
                      backgroundColor: _isLoading
                          ? tdGrey
                          : tdBlue, // Change color when disabled
                    ),
                    child: Text(_authForm == LOGIN
                        ? 'Login'
                        : _authForm == SIGNUP
                            ? 'Signup'
                            : "Update"),
                  ),

                  //  ----------------------------------------------------------------------------//
                  if (API_URL.contains("localhost:"))
                    ElevatedButton(
                      onPressed: _isLoading ? null : _tmp_login,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(color: tdBGColor),
                        backgroundColor: _isLoading
                            ? tdGrey
                            : tdBlue, // Change color when disabled
                      ),
                      child: const Text('Tmp Login'),
                    ),
                  //  ----------------------------------------------------------------------------//
                  const SizedBox(height: 20),
                  if (_authForm != UPDATE)
                    Column(children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _authForm == SIGNUP
                                      ? _authForm = LOGIN
                                      : _authForm = SIGNUP;
                                  errorMessage =
                                      ""; // Clear error message on form toggle
                                });
                              },
                        child: Text(
                          _authForm == LOGIN
                              ? 'not have account ? click here to Signup'
                              : 'already have an account! click here to Login',
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_authForm == LOGIN)
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _navigateToForgotPassword();
                                },
                          child: const Text(
                              'Forgor Password? click here to reset Password'),
                        ),
                      const SizedBox(height: 20),
                    ]),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: tdRed),
                    ),
                  if (_isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
