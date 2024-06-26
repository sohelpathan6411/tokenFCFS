import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tokenfcfs/screens/admin/admin_login_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Management System',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        appBarTheme: AppBarTheme(
            foregroundColor: Theme.of(context).primaryColorDark,
            backgroundColor: Colors.grey.shade100,
            actionsIconTheme: IconThemeData(
              color: Theme.of(context).primaryColorDark,
            ),
            titleTextStyle: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.w400,
                fontSize: 15),
            elevation: 0),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AdminLoginScreen(),
    );
  }
}
