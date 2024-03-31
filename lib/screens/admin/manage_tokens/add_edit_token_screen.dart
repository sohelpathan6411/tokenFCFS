import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:tokenfcfs/widgets/custom_text_field.dart';

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
      tokenNoController!.text = widget.token!['tokenNo'];
      jobNoController!.text = widget.token!['jobNo'];
      vehicleTypeController!.text = widget.token!['vehicleType'];
      vehicleNoController!.text = widget.token!['vehicleNo'];
      statusController!.text = widget.token!['status'];
      selectedServiceId = widget.token!['serviceId'];
      selectedUserId = widget.token!['userId'];
      selectedServiceName = widget.token!['serviceName'];
      selectedUserName = widget.token!['userName'];
      selectedUserPhone = widget.token!['userPhone'];
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
                          selectServiceWidget(snapshot),
                          const SizedBox(height: 15.0),
                          if (selectedServiceId != null)
                            Column(
                              children: [
                                selectUserWidget(),
                                const SizedBox(height: 16.0),
                                CustomTextField(
                                  label: 'Token No *',
                                  controller: tokenNoController,
                                  onChanged: (String value) {},
                                ),
                                const SizedBox(height: 16.0),
                                CustomTextField(
                                  label: 'Job No *',
                                  controller: jobNoController,
                                  onChanged: (String value) {},
                                ),
                                const SizedBox(height: 16.0),
                                CustomTextField(
                                  label: 'Vehicle Type *',
                                  controller: vehicleTypeController,
                                  onChanged: (String value) {},
                                ),
                                const SizedBox(height: 16.0),
                                CustomTextField(
                                  label: 'Vehicle No *',
                                  controller: vehicleNoController,
                                  onChanged: (String value) {},
                                ),
                                const SizedBox(height: 16.0),
                                const SizedBox(height: 15.0),
                                const SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    radioWidget('waiting', statusController!),
                                    radioWidget(
                                        'in-progress', statusController!),
                                    radioWidget('done', statusController!),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (selectedServiceId != null &&
                                        tokenNoController!.text.isNotEmpty &&
                                        jobNoController!.text.isNotEmpty &&
                                        vehicleTypeController!
                                            .text.isNotEmpty &&
                                        vehicleNoController!.text.isNotEmpty &&
                                        selectedUserId != null) {
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
                                        'vehicleNo': vehicleNoController!.text,
                                        'status': statusController!.text,
                                      };

                                      if (widget.token != null) {
                                        await FirebaseFirestore.instance
                                            .collection('tokens')
                                            .doc(widget.token!.id)
                                            .update(tokenData);
                                      } else {
                                        await FirebaseFirestore.instance
                                            .collection('tokens')
                                            .add(tokenData);
                                      }

                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Save'),
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
            color: Theme.of(context).primaryColor,
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
                        color: Theme.of(context).primaryColor,
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
