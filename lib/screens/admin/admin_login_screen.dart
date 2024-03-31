import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  String? _phoneNumber;
  String? _verificationId;
  String selectLoginRole = 'admin';

  Future<void> _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastLoginRole = await _getLastLoginRole();
    if (lastLoginRole != null) {
      // Perform auto-login based on the last logged-in role
      switch (lastLoginRole) {
        case 'admin':
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen()),
          );
          break;
        case 'operator':
          // ignore: use_build_context_synchronously
          /*  Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OperatorDashboardScreen()),
          ); */
          break;
        case 'user':
          // ignore: use_build_context_synchronously
          /* Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserDashboardScreen()),
          ); */
          break;
      }
    }
  }

  void initState() {
    super.initState();
    _autoLogin();
  }

  Future<void> _verifyPhoneNumber() async {
    verified(AuthCredential authResult) {
      FirebaseAuth.instance.signInWithCredential(authResult);
    }

    verificationFailed(FirebaseAuthException authException) {
      print('Error: ${authException.message}');
    }

    smsSent(String verId, [int? forceResend]) {
      _verificationId = verId;
    }

    autoTimeout(String verId) {
      _verificationId = verId;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$_phoneNumber',
      timeout: const Duration(seconds: 60),
      verificationCompleted: verified,
      verificationFailed: verificationFailed,
      codeSent: smsSent,
      codeAutoRetrievalTimeout: autoTimeout,
    );
  }

  Future<void> _signInWithOTP(String smsCode) async {
    AuthCredential authCreds = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: smsCode);

    await FirebaseAuth.instance.signInWithCredential(authCreds);
    // Store session information
    await _storeSession();
    // Navigate to the appropriate dashboard based on the last login role
    String? lastLoginRole = await _getLastLoginRole();
    if (lastLoginRole != null) {
      switch (lastLoginRole) {
        case 'admin':
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen()),
          );
          break;
        case 'operator':
          /* Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OperatorDashboardScreen()),
        ); */
          break;
        case 'user':
          /* Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboardScreen()),
        ); */
          break;
      }
    }
  }

  Future<void> _storeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lastLoginRole', 'admin'); // Store last login role as admin
    // Add more session information as needed
  }

  Future<String?> _getLastLoginRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastLoginRole'); // Default role is admin
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Login as",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  loginAsWidget(
                    'admin',
                  ),
                  loginAsWidget(
                    'operator',
                  ),
                  loginAsWidget(
                    'user',
                  ),
                ],
              ),
              TextField(
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Enter Phone Number'),
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _verifyPhoneNumber();
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(7),
                        title: const Text('Enter OTP'),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: OtpTextField(
                            numberOfFields: 6,
                            showFieldAsBox: true,
                            textStyle: const TextStyle(fontSize: 17),
                            onSubmit: (pin) {
                              if (pin.length == 6) {
                                _signInWithOTP(pin);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Verify Phone Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginAsWidget(
    String role,
  ) {
    return InkWell(
      onTap: () async {
        setState(() {
          selectLoginRole = role;
        });
      },
      child: Row(
        children: [
          selectLoginRole == role
              ? Icon(
                  Icons.radio_button_checked,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                )
              : const Icon(
                  Icons.radio_button_off,
                  size: 18,
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              role,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }
}
