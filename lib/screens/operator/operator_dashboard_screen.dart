import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tokenfcfs/widgets/custom_button.dart';

import '../../services/session_service.dart';
import '../../widgets/logout_button.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  DocumentSnapshot? user;
  String? phoneNumber;

  String? selectedServiceId;
  String? selectedServiceName;
  late final ScrollController _scrollController = ScrollController();
  late final ScrollController _scrollControllerForScrollbar =
      ScrollController();
  DocumentSnapshot? selectedTokenForService;
  late Stopwatch stopwatch;
  late Timer timer;

  String returnFormattedText() {
    var milli = stopwatch.elapsed.inMilliseconds;

    // this one for the miliseconds
    String seconds = ((milli ~/ 1000) % 60)
        .toString()
        .padLeft(2, "0"); // this is for the second
    String minutes = ((milli ~/ 1000) ~/ 60)
        .toString()
        .padLeft(2, "0"); // this is for the minute

    return "$minutes:$seconds";
  }

  initTask() async {
    phoneNumber = await SessionService().getLastLoginPhone();
    stopwatch = Stopwatch();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where("mobile", isEqualTo: phoneNumber)
        .where("role", isEqualTo: "operator")
        .get()
        .then((value) {
      setState(() {
        user = value.docs.first;
      });
    });
  }

  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    initTask();
    super.initState();
  }

  @override
  void dispose() {
    _scrollControllerForScrollbar.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Profile'),
        actions: const [
          LogOutButton(),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 15,
                            color: Colors.black87,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            user!['name'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            " (${user!['role']})",
                            style: const TextStyle(
                              fontSize: 15,
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
                                size: 15,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                user!['mobile'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('services')
                          .snapshots(),
                      builder: (context, snapshotServices) {
                        if (!snapshotServices.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return snapshotServices.data == null ||
                                snapshotServices.data!.docs.isEmpty
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                child: const Center(
                                    child: Text(
                                  'No Services found',
                                  textAlign: TextAlign.center,
                                )),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8.0),
                                  if (!stopwatch.isRunning)
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.95,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: selectServiceWidget(
                                              snapshotServices),
                                        )),
                                  const SizedBox(height: 8.0),
                                  SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: (!stopwatch.isRunning)
                                          ? (MediaQuery.of(context).size.width *
                                                  2 -
                                              100)
                                          : MediaQuery.of(context).size.width,
                                      child: StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('tokens')
                                              .where("serviceId",
                                                  isEqualTo: selectedServiceId
                                                      .toString())
                                              .orderBy('tokenNo')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            return snapshot.data == null ||
                                                    snapshot.data!.docs.isEmpty
                                                ? SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.95,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Text(
                                                        selectedServiceId ==
                                                                null
                                                            ? "Please select service to get token"
                                                            : "No Tokens found for selected service",
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  )
                                                : Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // Block A - Tokens List
                                                      if (!stopwatch.isRunning)
                                                        Expanded(
                                                          flex: 15,
                                                          child:
                                                              _buildTokensList(
                                                                  snapshot),
                                                        ),
                                                      // Block B - Timer and Start/Stop Button
                                                      Container(
                                                        color: Colors.black54,
                                                        width: 1,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.7,
                                                      ),
                                                      Expanded(
                                                        flex: 16,
                                                        child:
                                                            _buildTimerBlock(),
                                                      ),
                                                    ],
                                                  );
                                          }),
                                    ),
                                  ),
                                ],
                              );
                      }),
                ],
              ),
            ),
    );
  }

  Widget _buildTokensList(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    return Container(
      color: Colors.blueGrey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Tap below token for more actions",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7 - 80,
            child: ScrollbarTheme(
              data: const ScrollbarThemeData(
                  thumbColor: MaterialStatePropertyAll(Colors.grey)),
              child: Scrollbar(
                thickness: 4,
                trackVisibility: true,
                thumbVisibility: true,
                interactive: true,
                controller: _scrollControllerForScrollbar,
                scrollbarOrientation: ScrollbarOrientation.right,
                child: ListView.builder(
                  controller: _scrollControllerForScrollbar,
                  itemCount: snapshot.data?.docs.length,
                  scrollDirection: Axis.vertical,
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
                            onTap: () {
                              if (token['status'] != 'done') {
                                setState(() {
                                  selectedTokenForService = token;
                                });

                                _scrollTo(
                                    MediaQuery.of(context).size.width - 100);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Service is already finished",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red.shade800,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
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
                                              : "${token['timeSpent']} Mins",
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBlock() {
    // Implement timer and start/stop button here
    return Container(
      color: Colors.green.shade50,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (selectedTokenForService == null)
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "No token selected from left menu",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
            if (selectedTokenForService != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.car_crash,
                        size: 22,
                        color: Colors.black87,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        selectedTokenForService!['vehicleNo'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text(
                      "Token No: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      selectedTokenForService!['tokenNo'].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    height: 150,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape
                          .circle, // this one is use for make the circle on ui.
                      border: Border.all(
                        color: Theme.of(context).primaryColorDark,
                        width: 4,
                      ),
                    ),
                    child: Text(
                      returnFormattedText(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  !stopwatch.isRunning
                      ? CustomButton(
                          // this the cupertino button and here we perform all the reset button function
                          onPressed: () async {
                            if (!stopwatch.isRunning &&
                                selectedTokenForService != null) {
                              Map<String, dynamic> tokenData = {
                                'serviceId':
                                    selectedTokenForService!['serviceId'],
                                'serviceName':
                                    selectedTokenForService!['serviceName'],
                                'userId': selectedTokenForService!['userId'],
                                'userName':
                                    selectedTokenForService!['userName'],
                                'userPhone':
                                    selectedTokenForService!['userPhone'],
                                'tokenNo': selectedTokenForService!['tokenNo'],
                                'jobNo': selectedTokenForService!['jobNo'],
                                'vehicleType':
                                    selectedTokenForService!['vehicleType'],
                                'vehicleNo':
                                    selectedTokenForService!['vehicleNo'],
                                'status': "in-progress",
                                'timeSpent': "0",
                              };
                              await FirebaseFirestore.instance
                                  .collection('tokens')
                                  .doc(selectedTokenForService!.id)
                                  .update(tokenData);
                              Fluttertoast.showToast(
                                  msg: "Service is started",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor:
                                      // ignore: use_build_context_synchronously
                                      Theme.of(context).primaryColorDark,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              setState(() {
                                stopwatch.start();
                              });
                            }
                          },

                          text: "Start Service",
                        )
                      : CustomButton(
                          // this the cupertino button and here we perform all the reset button function
                          onPressed: () async {
                            if (stopwatch.isRunning &&
                                selectedTokenForService != null) {
                              Map<String, dynamic> tokenData = {
                                'serviceId':
                                    selectedTokenForService!['serviceId'],
                                'serviceName':
                                    selectedTokenForService!['serviceName'],
                                'userId': selectedTokenForService!['userId'],
                                'userName':
                                    selectedTokenForService!['userName'],
                                'userPhone':
                                    selectedTokenForService!['userPhone'],
                                'tokenNo': selectedTokenForService!['tokenNo'],
                                'jobNo': selectedTokenForService!['jobNo'],
                                'vehicleType':
                                    selectedTokenForService!['vehicleType'],
                                'vehicleNo':
                                    selectedTokenForService!['vehicleNo'],
                                'status': "done",
                                'timeSpent': returnFormattedText(),
                              };
                              await FirebaseFirestore.instance
                                  .collection('tokens')
                                  .doc(selectedTokenForService!.id)
                                  .update(tokenData);
                              Fluttertoast.showToast(
                                  msg: "Service is finished",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              setState(() {
                                stopwatch.stop();
                                stopwatch.reset();
                                selectedTokenForService = null;
                              });
                            }
                          },
                          text: "Done Service",
                        ),
                ],
              ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget selectServiceWidget(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
            style: const TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
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
}
