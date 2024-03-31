import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tokenfcfs/widgets/custom_button.dart';
import 'package:tokenfcfs/widgets/custom_text_field.dart';

import '../../../services/token_service.dart';
import '../../../services/uppercase_formatter.dart';

class AddEditTokenScreen extends StatefulWidget {
  final DocumentSnapshot? token;

  const AddEditTokenScreen({Key? key, this.token}) : super(key: key);

  @override
  State<AddEditTokenScreen> createState() => _AddEditTokenScreenState();
}

class _AddEditTokenScreenState extends State<AddEditTokenScreen> {
  final TextEditingController? tokenNoController = TextEditingController();
  final TextEditingController? jobNoController = TextEditingController();
  final TextEditingController? vehicleTypeController = TextEditingController();
  final TextEditingController? vehicleNoController = TextEditingController();

  final TextEditingController? statusController =
      TextEditingController(text: 'waiting');

  String? selectedServiceId;
  String? selectedUserId;
  String? selectedServiceName;
  String? selectedUserName;
  String? selectedUserPhone;

  @override
  void initState() {
    if (widget.token != null) {
      tokenNoController!.text = widget.token!['tokenNo'].toString();
      jobNoController!.text = widget.token!['jobNo'].toString();
      vehicleTypeController!.text = widget.token!['vehicleType'];
      vehicleNoController!.text = widget.token!['vehicleNo'];
      statusController!.text = widget.token!['status'];
      selectedServiceId = widget.token!['serviceId'];
      selectedUserId = widget.token!['userId'];
      selectedServiceName = widget.token!['serviceName'];
      selectedUserName = widget.token!['userName'];
      selectedUserPhone = widget.token!['userPhone'];
    } else {
      generateTokenAndJobNo().then((value) {
        setState(() {
          tokenNoController!.text = value['tokenNo'].toString();
          jobNoController!.text = value['jobNo'].toString();
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.token != null ? 'Edit Token' : 'Add Token'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return snapshot.data == null || snapshot.data!.docs.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: const Center(
                            child: Text(
                          'No Services found,\n\nPlease add services then you can generate token.',
                          textAlign: TextAlign.center,
                        )),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 15.0),
                          if (tokenNoController!.text.isNotEmpty)
                            Row(
                              children: [
                                const Text(
                                  "Token No: ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                if (tokenNoController!.text.isNotEmpty)
                                  Text(
                                    tokenNoController!.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Text("Job No: "),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (jobNoController!.text.isNotEmpty)
                                      Text(jobNoController!.text),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 16.0),
                          selectServiceWidget(snapshot),
                          const SizedBox(height: 15.0),
                          if (selectedServiceId != null)
                            Column(
                              children: [
                                selectUserWidget(),
                                const SizedBox(height: 16.0),
                                CustomTextField(
                                  label: 'Vehicle Type * (eg. Car, Bus, etc)',
                                  controller: vehicleTypeController,
                                  onChanged: (String value) {},
                                ),
                                const SizedBox(height: 16.0),
                                CustomTextField(
                                  label: 'Vehicle No * (eg. MH-03-2349)',
                                  controller: vehicleNoController,
                                  onChanged: (String value) {},
                                  inputformate: <TextInputFormatter>[
                                    UpperCaseTextFormatter()
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    radioWidget('waiting', statusController!),
                                    radioWidget(
                                        'in-progress', statusController!),
                                    radioWidget('done', statusController!),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: CustomButton(
                                    onPressed: () async {
                                      if (selectedServiceId != null &&
                                          tokenNoController!.text.isNotEmpty &&
                                          jobNoController!.text.isNotEmpty &&
                                          vehicleTypeController!
                                              .text.isNotEmpty &&
                                          vehicleNoController!
                                              .text.isNotEmpty &&
                                          selectedUserId != null) {
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

                                        if (widget.token != null) {
                                          Map<String, dynamic> tokenData = {
                                            'serviceId': selectedServiceId,
                                            'serviceName': selectedServiceName,
                                            'userId': selectedUserId,
                                            'userName': selectedUserName,
                                            'userPhone': selectedUserPhone,
                                            'tokenNo': tokenNoController!.text,
                                            'jobNo': jobNoController!.text,
                                            'vehicleType':
                                                vehicleTypeController!.text,
                                            'vehicleNo':
                                                vehicleNoController!.text,
                                            'status': statusController!.text,
                                            'timeSpent':
                                                widget.token!['timeSpent']
                                          };
                                          await FirebaseFirestore.instance
                                              .collection('tokens')
                                              .doc(widget.token!.id)
                                              .update(tokenData);
                                        } else {
                                          Map<String, dynamic> tokenData = {
                                            'serviceId': selectedServiceId,
                                            'serviceName': selectedServiceName,
                                            'userId': selectedUserId,
                                            'userName': selectedUserName,
                                            'userPhone': selectedUserPhone,
                                            'tokenNo': int.parse(
                                                tokenNoController!.text),
                                            'jobNo': int.parse(
                                                jobNoController!.text),
                                            'vehicleType':
                                                vehicleTypeController!.text,
                                            'vehicleNo':
                                                vehicleNoController!.text,
                                            'status': statusController!.text,
                                            'timeSpent': '-'
                                          };
                                          await FirebaseFirestore.instance
                                              .collection('tokens')
                                              .add(tokenData);
                                        }

                                        Navigator.pop(context);
                                      }
                                    },
                                    text: 'Save',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      );
              }),
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

  Widget selectServiceWidget(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            hint: Text(selectedServiceId == null
                ? "Select Service"
                : selectedServiceName!),
            style: TextStyle(
                fontSize: selectedServiceId == null ? 14 : 16,
                color: Colors.black,
                fontWeight: selectedServiceId == null
                    ? FontWeight.w500
                    : FontWeight.w600),
            items: snapshot.data!.docs.map((DocumentSnapshot item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item['name'],
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedServiceId = value!.id;
                selectedServiceName = value['name'];
              });
            }),
      ),
    );
  }

  Widget selectUserWidget() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("role", isEqualTo: "user")
            .snapshots(),
        builder: (context, snapshotUser) {
          if (!snapshotUser.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return snapshotUser.data == null || snapshotUser.data!.docs.isEmpty
              ? const Center(
                  child: Text(
                  'No Users found!',
                ))
              : InputDecorator(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColorDark,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                        hint: Text(selectedUserId == null
                            ? "Select User"
                            : selectedUserName!),
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: selectedUserId == null
                                ? FontWeight.w500
                                : FontWeight.w600),
                        items: snapshotUser.data!.docs
                            .map((DocumentSnapshot item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value!.id;
                            selectedUserName = value['name'];
                            selectedUserPhone = value['mobile'];
                          });
                        }),
                  ),
                );
        });
  }
}
