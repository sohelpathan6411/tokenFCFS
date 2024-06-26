import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tokenfcfs/widgets/custom_button.dart';
import 'package:tokenfcfs/widgets/custom_text_field.dart';

class AddEditServiceScreen extends StatefulWidget {
  final DocumentSnapshot? service;

  const AddEditServiceScreen({Key? key, this.service}) : super(key: key);

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final TextEditingController? nameController = TextEditingController();

  final TextEditingController? descController = TextEditingController();

  @override
  void initState() {
    if (widget.service != null) {
      nameController!.text = widget.service!['name'];
      descController!.text = widget.service!['desc'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service != null ? 'Edit Service' : 'Add Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20.0),
              CustomTextField(
                label: 'Name *',
                controller: nameController,
                onChanged: (String value) {},
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                label: 'Description *',
                onChanged: (String value) {},
                controller: descController,
              ),
              const SizedBox(height: 20.0),
              CustomButton(
                onPressed: () async {
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
                  if (nameController!.text.isNotEmpty &&
                      descController!.text.isNotEmpty) {
                    Map<String, dynamic> serviceData = {
                      'name': nameController!.text,
                      'desc': descController!.text,
                    };

                    if (widget.service != null) {
                      await FirebaseFirestore.instance
                          .collection('services')
                          .doc(widget.service!.id)
                          .update(serviceData);
                    } else {
                      await FirebaseFirestore.instance
                          .collection('services')
                          .add(serviceData);
                    }

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
}
