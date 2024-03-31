import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tokenfcfs/widgets/custom_button.dart';
import 'package:tokenfcfs/widgets/custom_text_field.dart';

import '../../services/session_service.dart';
import '../user/user_dashboard_screen.dart';

class RegisterUserScreen extends StatefulWidget {
  final String? mobileNumber;

  const RegisterUserScreen({Key? key, this.mobileNumber}) : super(key: key);

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final TextEditingController? nameController = TextEditingController();

  final TextEditingController? mobileController = TextEditingController();

  final TextEditingController? statusController =
      TextEditingController(text: 'active');

  final TextEditingController? roleController =
      TextEditingController(text: 'user');

  @override
  void initState() {
    if (widget.mobileNumber != null) {
      mobileController!.text = widget.mobileNumber!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40.0),
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
              Text(
                mobileController!.text,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              CustomTextField(
                label: 'Name *',
                controller: nameController,
                onChanged: (String value) {},
              ),
              const SizedBox(height: 30.0),
              CustomButton(
                onPressed: () async {
                  if (nameController!.text.isNotEmpty &&
                      mobileController!.text.isNotEmpty) {
                    Map<String, dynamic> userData = {
                      'name': nameController!.text,
                      'mobile': mobileController!.text,
                      'status': 'active',
                      'role': 'user',
                    };

                    await FirebaseFirestore.instance
                        .collection('users')
                        .add(userData);
                    Fluttertoast.showToast(
                        msg: "Profile has been created",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor:
                            // ignore: use_build_context_synchronously
                            Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    await SessionService()
                        .storeSession("user", mobileController!.text);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserDashboardScreen()),
                    );
                  }
                },
                text: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
