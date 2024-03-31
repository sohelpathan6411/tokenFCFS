import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_edit_token_screen.dart';

class TokenManagementScreen extends StatelessWidget {
  const TokenManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Management'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tokens').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return snapshot.data == null || snapshot.data!.docs.isEmpty
              ? const Center(
                  child: Text(
                  'No Tokens found!',
                ))
              : ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot token = snapshot.data!.docs[index];

                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          tileColor: Colors.white,
                          title: Row(
                            children: [
                              const Icon(
                                Icons.car_crash,
                                size: 14,
                                color: Colors.black87,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                token['vehicleNo'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: token['status'] == "done"
                                        ? Colors.green
                                        : (token['status'] == "waiting"
                                            ? Colors.blueGrey
                                            : Colors.deepOrange),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 3),
                                  child: Text(
                                    token['status'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
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
                                  Text(
                                    token['tokenNo'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Text("Job No: "),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(token['jobNo']),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(token['userName']),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 14,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(token['userPhone']),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const Text("Vehicle Type: "),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(token['vehicleType']),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade800,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('tokens')
                                  .doc(token.id)
                                  .delete();
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditTokenScreen(token: token)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTokenScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
