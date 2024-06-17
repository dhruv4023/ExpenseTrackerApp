import 'dart:convert';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();

  bool _disableEmailField = false;
  bool _loading = false;
  String? _errMsg;

  void _handleSendOTP() async {
    setState(() {
      _loading = true;
      _errMsg = null;
    });

    String email = _emailController.text.trim();

    try {
      if (email.isEmpty) {
        setState(() {
          _errMsg = 'Enter email to send OTP';
        });
      } else {
        // Your send OTP logic goes here

        final String sendOtpUrl = '$API_URL/mail/send-otp';

        final sendOtpResponse = await http.post(
          Uri.parse(sendOtpUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'email': email}),
        );

        if (sendOtpResponse.statusCode == 200) {
          setState(() {
            _disableEmailField = true;
            _errMsg = null;
          });
          // Show alert for successful OTP sending
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text("OTP sent successfully"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          Map<String, dynamic> senOtpResponseData =
              jsonDecode(sendOtpResponse.body);
          setState(() {
            _errMsg = senOtpResponseData['message'];
          });
        }
      }
    } catch (error) {
      setState(() {
        _errMsg = 'Error sending OTP';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _handleFormSubmitChangePass() async {
    setState(() {
      _loading = true;
      _errMsg = null;
    });

    String email = _emailController.text.trim();
    String otp = _otpController.text.trim();
    String password = _passwordController.text.trim();
    String repass = _repassController.text.trim();

    try {
      if (password != repass) {
        setState(() {
          _errMsg = 'Please enter both passwords the same';
        });
      } else if (otp.length != 6) {
        setState(() {
          _errMsg = 'Enter 6 Digit OTP';
        });
      } else {
        final String changePassUrl = '$API_URL/auth/change/password';

        final sendOtpResponse = await http.post(
          Uri.parse(changePassUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'email': email,
            'otp': otp,
            'password': password,
          }),
        );

        if (sendOtpResponse.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text("Password changed successfully!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Map<String, dynamic> senOtpResponseData =
              jsonDecode(sendOtpResponse.body);

          setState(() {
            _errMsg = senOtpResponseData['message'];
          });
        }
      }
    } catch (error) {
      // Handle error
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              enabled: !_disableEmailField,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loading || _disableEmailField ? null : _handleSendOTP,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(color: Colors.white),
                backgroundColor: _loading
                    ? Colors.grey
                    : Colors.blue, // Change color when disabled
              ),
              child: const Text('Send OTP'),
            ),
            if (_disableEmailField)
              Column(
                children: [
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  TextField(
                    controller: _repassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Re-Enter Password',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _loading ? null : _handleFormSubmitChangePass,
                    child: Text('Change'),
                  ),
                ],
              ),
            if (_errMsg != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _errMsg!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (_loading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
