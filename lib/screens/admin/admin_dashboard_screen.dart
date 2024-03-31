import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout() async {
    // Clear session information
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Perform logout action
              await _logout();
              // Navigate to LoginScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to Manage Users screen
              },
              child: const Text('Manage Users'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Manage Services screen
              },
              child: const Text('Manage Services'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Manage Tokens screen
              },
              child: const Text('Manage Tokens'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Visualization Reports screen
              },
              child: const Text('Visualization Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
