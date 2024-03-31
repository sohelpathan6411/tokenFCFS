import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import 'admin_login_screen.dart';
import 'manage_services/service_management_screen.dart';
import 'manage_tokens/token_management_screen.dart';
import 'manage_users/user_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Perform logout action
              await SessionService().logout();
              // Navigate to LoginScreen
              // ignore: use_build_context_synchronously

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserManagementScreen()),
                    );
                  },
                  child: optionsMenu('Manage Users', context),
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
                  child: optionsMenu('Manage Services', context),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TokenManagementScreen()),
                    );
                  },
                  child: optionsMenu('Manage Tokens', context),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserManagementScreen()),
                    );
                  },
                  child: optionsMenu('Reports', context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget optionsMenu(title, context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: 100,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            border: Border.all(
              width: 1,
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 16),
          ),
        )),
      ),
    );
  }
}
