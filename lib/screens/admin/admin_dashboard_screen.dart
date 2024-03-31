import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../widgets/logout_button.dart';
import 'manage_services/service_management_screen.dart';
import 'manage_tokens/token_management_screen.dart';
import 'manage_users/user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  QuerySnapshot? usersData;
  QuerySnapshot? servicesData;
  QuerySnapshot? tokensData;

  initTask() async {
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');
    CollectionReference tokensCollection =
        FirebaseFirestore.instance.collection('tokens');
    CollectionReference servicesCollection =
        FirebaseFirestore.instance.collection('services');

    usersData = await userCollection.get();
    servicesData = await tokensCollection.get();
    tokensData = await servicesCollection.get();

    setState(() {});
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
        title: const Text('Admin Dashboard'),
        actions: const [
          LogOutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          initTask();
          Fluttertoast.showToast(
              msg: "Refreshed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor:
                  // ignore: use_build_context_synchronously
                  Theme.of(context).primaryColorDark,
              textColor: Colors.white,
              fontSize: 16.0);
        },
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      "Pull to refresh",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Colors.blueGrey),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const UserManagementScreen()),
                        );
                      },
                      child: optionsMenu('Users', context),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ServiceManagementScreen()),
                        );
                      },
                      child: optionsMenu('Services', context),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TokenManagementScreen()),
                        );
                      },
                      child: optionsMenu('Tokens', context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Tokens Analysis",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16),
                  ),
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('tokens')
                        .orderBy('tokenNo')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return snapshot.data == null ||
                              snapshot.data!.docs.isEmpty
                          ? const Center(
                              child: Text(
                              'No Tokens found!',
                            ))
                          : PieChart(
                              dataMap: {
                                "waiting": snapshot.data!.docs
                                    .where((element) =>
                                        element['status'] == "waiting")
                                    .toList()
                                    .length
                                    .toDouble(),
                                "in-progress": snapshot.data!.docs
                                    .where((element) =>
                                        element['status'] == "in-progress")
                                    .toList()
                                    .length
                                    .toDouble(),
                                "done": snapshot.data!.docs
                                    .where((element) =>
                                        element['status'] == "done")
                                    .toList()
                                    .length
                                    .toDouble(),
                              },
                              animationDuration: const Duration(seconds: 2),
                              chartLegendSpacing: 32,
                              chartRadius:
                                  MediaQuery.of(context).size.width / 3.5,
                              colorList: const <Color>[
                                Colors.grey,
                                Colors.red,
                                Colors.green,
                              ],
                              initialAngleInDegree: 0,
                              chartType: ChartType.ring,
                              ringStrokeWidth: 32,
                              centerText: "Tokens",
                              legendOptions: const LegendOptions(
                                showLegendsInRow: false,
                                legendPosition: LegendPosition.right,
                                showLegends: true,
                                legendShape: BoxShape.circle,
                                legendTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              chartValuesOptions: const ChartValuesOptions(
                                showChartValueBackground: true,
                                showChartValues: true,
                                showChartValuesInPercentage: false,
                                showChartValuesOutside: false,
                                decimalPlaces: 1,
                              ),
                            );
                    }),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "General Analysis",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16),
                  ),
                ),
                if (usersData != null)
                  PieChart(
                    dataMap: {
                      "Users": usersData!.size.toDouble(),
                      "Services": servicesData!.size.toDouble(),
                      "Tokens": tokensData!.size.toDouble(),
                    },
                    animationDuration: const Duration(microseconds: 1),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 3.5,
                    colorList: const <Color>[
                      Colors.greenAccent,
                      Colors.indigo,
                      Colors.orange,
                    ],
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    centerText: "",
                    legendOptions: const LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.left,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget optionsMenu(title, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            border: Border.all(
              width: 1,
              color: Theme.of(context).primaryColorDark,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    fontSize: 14),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 10)
            ],
          ),
        )),
      ),
    );
  }
}
