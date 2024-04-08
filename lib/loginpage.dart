// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, sort_child_properties_last



import 'package:afronex_task_4/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Loginpage extends StatefulWidget {
  Loginpage({Key? key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  bool isPasswordVisible = false;

  void login() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailcontroller.text,
        password: passwordcontroller.text,
      );
      print("succ");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print("-------------------" + e.code);
      Navigator.pop(context);

      if (e.code == 'invalid-credential') {
        errors();
      } else if (e.code == 'invalid-email') {
        error2();
      }
    }
  }

  void error2() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: 50,
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "Invalid Email",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Ok'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(
                      color: const Color.fromARGB(255, 220, 177, 174),
                      width: 2, // Border thickness
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void errors() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: 50,
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "Incorrect Credential",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Ok'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(
                      color: const Color.fromARGB(255, 220, 177, 174),
                      width: 2, // Border thickness
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 90,
              ),
              Image.asset(
                "asset/image/3.png",
                width: 200,
                height: 150,
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailcontroller,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: passwordcontroller,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot password",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xffBA09FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: login,
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(55),
                        backgroundColor: Color.fromARGB(255, 121, 0, 169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("OR"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Signup(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xffBA09FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
