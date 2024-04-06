import 'dart:async';

import 'package:afronex_task_4/auth.dart';

import 'package:flutter/material.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      ()=>Navigator.push(context,MaterialPageRoute(
        builder: (context)=>Authpage(),



        )));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
              image: AssetImage("asset/image/4.jpg"),
              fit: BoxFit.cover,
              opacity: 0.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [



            Image(
  image: AssetImage('asset/image/3.png'),
  width: 200,
  height: 200,
),

Text(
  "Digital Shop",
  style: TextStyle(
    color: Colors.white,
    fontSize: 40,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
  ),
),


          ],
        ),
      ),
    );
  }
}
