import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:my_app/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل متغيرات البيئة
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }

  // تهيئة Firebase
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
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const AuthWrapper(), // التطبيق يفتح مباشرة
    );
  }
}
