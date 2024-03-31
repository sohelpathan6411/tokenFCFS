import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../services/session_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
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
    String? lastLoginRole = await SessionService().getLastLoginRole();
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
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(7),
            title: const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
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
    await SessionService().storeSession(selectLoginRole);
    // Navigate to the appropriate dashboard based on the last login role
    String? lastLoginRole = await SessionService().getLastLoginRole();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomTextField(
                  keyboardType: TextInputType.phone,
                  label: 'Enter Phone Number',
                  maxLength: 10,
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Verify Phone Number',
                  onPressed: () async {
                    if (await FirebaseFirestore.instance
                        .collection('users')
                        .where("mobile", isEqualTo: _phoneNumber)
                        .where("role", isEqualTo: "admin")
                        .get()
                        .then((value) => value.size > 0 ? true : false)) {
                      setState(() {
                        selectLoginRole = 'admin';
                      });
                    } else if (await FirebaseFirestore.instance
                        .collection('users')
                        .where("mobile", isEqualTo: _phoneNumber)
                        .where("role", isEqualTo: "operator")
                        .get()
                        .then((value) => value.size > 0 ? true : false)) {
                      setState(() {
                        selectLoginRole = 'operator';
                      });
                    } else if (await FirebaseFirestore.instance
                        .collection('users')
                        .where("mobile", isEqualTo: _phoneNumber)
                        .where("role", isEqualTo: "user")
                        .get()
                        .then((value) => value.size > 0 ? true : false)) {
                      setState(() {
                        selectLoginRole = 'user';
                      });
                    }
                    await _verifyPhoneNumber();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
