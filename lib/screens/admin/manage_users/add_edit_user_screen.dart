import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tokenfcfs/widgets/custom_button.dart';
import 'package:tokenfcfs/widgets/custom_text_field.dart';

class AddEditUserScreen extends StatefulWidget {
  final DocumentSnapshot? user;

  const AddEditUserScreen({Key? key, this.user}) : super(key: key);

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final TextEditingController? nameController = TextEditingController();

  final TextEditingController? mobileController = TextEditingController();

  final TextEditingController? statusController =
      TextEditingController(text: 'active');

  final TextEditingController? roleController =
      TextEditingController(text: 'user');

  @override
  void initState() {
    if (widget.user != null) {
      nameController!.text = widget.user!['name'];
      mobileController!.text = widget.user!['mobile'];
      statusController!.text = widget.user!['status'];
      roleController!.text = widget.user!['role'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user != null ? 'Edit User' : 'Add User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40.0),
              CustomTextField(
                label: 'Name *',
                controller: nameController,
                onChanged: (String value) {},
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                label: 'Mobile (10 Digits)*',
                maxLength: 10,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputformate: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (String value) {},
                controller: mobileController,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  radioWidget('active', statusController!),
                  radioWidget('inactive', statusController!),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  radioWidget('admin', roleController!),
                  radioWidget('operator', roleController!),
                  radioWidget('user', roleController!),
                ],
              ),
              const SizedBox(height: 30.0),
              CustomButton(
                onPressed: () async {
                  if (nameController!.text.isNotEmpty &&
                      mobileController!.text.isNotEmpty) {
                    Fluttertoast.showToast(
                        msg: "Saved",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor:
                            // ignore: use_build_context_synchronously
                            Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Map<String, dynamic> userData = {
                      'name': nameController!.text,
                      'mobile': mobileController!.text,
                      'status': statusController!.text,
                      'role': roleController!.text,
                    };

                    if (widget.user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user!.id)
                          .update(userData);
                    } else {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .add(userData);
                    }

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
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

  Widget radioWidget(String status, TextEditingController controller) {
    return InkWell(
      onTap: () async {
        setState(() {
          controller.text = status;
        });
      },
      child: Row(
        children: [
          controller.text == status
              ? Icon(
                  Icons.radio_button_checked,
                  color: Theme.of(context).primaryColorDark,
                  size: 18,
                )
              : const Icon(
                  Icons.radio_button_off,
                  size: 18,
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              status,
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
