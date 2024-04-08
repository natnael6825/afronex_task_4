// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, sort_child_properties_last



import 'package:afronex_task_4/homepage.dart';
import 'package:afronex_task_4/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authpage extends StatelessWidget {
  const Authpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Homepage();
          } else {
            return Loginpage();
          }
        },
      ),
    );
  }
}
