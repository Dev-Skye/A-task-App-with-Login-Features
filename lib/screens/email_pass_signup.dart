import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_page/config/config.dart';

class EmailPassSignupScrenn extends StatefulWidget {
  @override
  _EmailPassSignupScrennState createState() => _EmailPassSignupScrennState();
}

class _EmailPassSignupScrennState extends State<EmailPassSignupScrenn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 40),
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email",
                      hintText: "Write Email Here"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                      hintText: "Write Password Here"),
                  obscureText: true,
                ),
              ),
              InkWell(
                onTap: () {
                  _signUp();
                },
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor]),
                      borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Center(
                      child: Text(
                    "SignUp Using Email",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() {
    final String emailTXT = _emailController.text.trim();
    final String passwordTXT = _passwordController.text;

    if (emailTXT.isNotEmpty && passwordTXT.isNotEmpty) {
      _auth
          .createUserWithEmailAndPassword(
              email: emailTXT, password: passwordTXT)
          .then((user) {
        _db.collection("user").doc(user.user.uid).set({
          "email": emailTXT,
          "lastseen": DateTime.now(),
          "signin _method": user.user.providerData,
        });

        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text("Success"),
                content: Text("Sign Up Process done, Sign In Now!"),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text("Error"),
                content: Text("${e.message}"),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      });
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text("Error"),
              content: Text("Please provide email and password"),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }
}
