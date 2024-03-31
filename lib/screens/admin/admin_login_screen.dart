import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/session_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../operator/operator_dashboard_screen.dart';
import '../user/user_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'register_user_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  String? _phoneNumber;
  String? _verificationId;
  String selectLoginRole = 'user';

  Future<void> _autoLogin() async {
    String? lastLoginRole = await SessionService().getLastLoginRole();
    if (lastLoginRole != null) {
      roleBaseNavigation(lastLoginRole);
    }
  }

  roleBaseNavigation(lastLoginRole) {
    switch (lastLoginRole) {
      case 'admin':
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
        break;
      case 'operator':
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const OperatorDashboardScreen()),
        );
        break;
      case 'user':
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserDashboardScreen()),
        );
        break;
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
            title: Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 160,
              child: OtpTextField(
                numberOfFields: 6,
                showFieldAsBox: true,
                clearText: true,
                textStyle: const TextStyle(fontSize: 17),
                onSubmit: (pin) {
                  if (pin.length == 6) {
                    _signInWithOTP(pin);
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
    Fluttertoast.showToast(
        msg: "Validating...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor:
            // ignore: use_build_context_synchronously
            Theme.of(context).primaryColor,
        textColor: Colors.white,
        fontSize: 16.0);
    AuthCredential authCreds = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: smsCode);

    try {
      await FirebaseAuth.instance.signInWithCredential(authCreds);
      // Store session information
      if (selectLoginRole != "newuser") {
        await SessionService().storeSession(selectLoginRole, _phoneNumber);
      }

      // Navigate to the appropriate dashboard based on the last login role
      String? lastLoginRole = await SessionService().getLastLoginRole();
      if (lastLoginRole != null) {
        Navigator.pop(context);
        roleBaseNavigation(lastLoginRole);
      } else {
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RegisterUserScreen(mobileNumber: _phoneNumber)),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Enter valid OTP Or Please request another OTP",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor:
              // ignore: use_build_context_synchronously
              Colors.red.shade800,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Manage services, tokens, users and much more",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 40,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CustomButton(
                    text: 'Verify Phone Number',
                    onPressed: () async {
                      if ((_phoneNumber ?? "").length == 10) {
                        Fluttertoast.showToast(
                            msg: "Sending OTP...",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 1,
                            backgroundColor:
                                // ignore: use_build_context_synchronously
                                Theme.of(context).primaryColorDark,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        if (await FirebaseFirestore.instance
                            .collection('users')
                            .where("mobile", isEqualTo: _phoneNumber)
                            .where("role", isEqualTo: "admin")
                            .get()
                            .then((value) => value.size > 0 ? true : false)) {
                          setState(() {
                            selectLoginRole = 'admin';
                          });
                          await _verifyPhoneNumber();
                        } else if (await FirebaseFirestore.instance
                            .collection('users')
                            .where("mobile", isEqualTo: _phoneNumber)
                            .where("role", isEqualTo: "operator")
                            .get()
                            .then((value) => value.size > 0 ? true : false)) {
                          setState(() {
                            selectLoginRole = 'operator';
                          });
                          await _verifyPhoneNumber();
                        } else if (await FirebaseFirestore.instance
                            .collection('users')
                            .where("mobile", isEqualTo: _phoneNumber)
                            .where("role", isEqualTo: "user")
                            .get()
                            .then((value) => value.size > 0 ? true : false)) {
                          setState(() {
                            selectLoginRole = 'user';
                          });
                          await _verifyPhoneNumber();
                        } else {
                          setState(() {
                            selectLoginRole = 'newuser';
                          });
                          await _verifyPhoneNumber();
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "10 Digits number is required",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 1,
                            backgroundColor:
                                // ignore: use_build_context_synchronously
                                Colors.red.shade800,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
