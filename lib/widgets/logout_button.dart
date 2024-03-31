import 'package:flutter/material.dart';

import '../screens/admin/admin_login_screen.dart';
import '../services/session_service.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        // Perform logout action
        await SessionService().logout();

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        );
      },
    );
  }
}
