


import 'package:afronex_task_4/adder.dart';
import 'package:afronex_task_4/loginpage.dart';
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
