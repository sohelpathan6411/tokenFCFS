import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/session_service.dart';
import '../../widgets/logout_button.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  DocumentSnapshot? user;
  String? phoneNumber;
  initTask() async {
    phoneNumber = await SessionService().getLastLoginPhone();
    await FirebaseFirestore.instance
        .collection('users')
        .where("mobile", isEqualTo: phoneNumber)
        .where("role", isEqualTo: "user")
        .get()
        .then((value) {
      setState(() {
        user = value.docs.first;
      });
    });
  }

  @override
  void initState() {
    initTask();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: const [
          LogOutButton(),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 12),
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 22,
                              color: Colors.black87,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              user!['name'],
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              " (${user!['role']})",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                  color: user!['status'] == "active"
                                      ? Colors.green
                                      : Colors.red.shade800,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 3),
                                child: Text(
                                  user!['status'],
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
                                const Icon(
                                  Icons.phone,
                                  size: 22,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  user!['mobile'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  _tokeList()
                ],
              ),
            ),
    );
  }

  Widget _tokeList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tokens')
            .where("userPhone", isEqualTo: user!['mobile'].toString())
            .orderBy('tokenNo')
            .snapshots(),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                                      token['tokenNo'].toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Text("Job No: "),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          token['jobNo'].toString(),
                                        ),
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
                                    const Text("Type: "),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(token['vehicleType']),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Text(
                                          "Time: ",
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          (token['timeSpent'] ?? '0') == '0' ||
                                                  (token['timeSpent'] ?? '0') ==
                                                      '-'
                                              ? "-"
                                              : ("${token['timeSpent']} Mins"),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
