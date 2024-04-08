
// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, sort_child_properties_last





import 'package:afronex_task_4/splashscreen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';





Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
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

    theme: ThemeData(
primaryColor: Color.fromARGB(255, 121, 0, 169),
    ) ,


home: splashScreen(),


    );
  }
}
