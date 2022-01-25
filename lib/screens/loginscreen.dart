import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_page/config/config.dart';
import 'package:login_page/screens/email_pass_signup.dart';
import 'package:login_page/screens/homescreen.dart';
import 'package:login_page/screens/phone_signin.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 80),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Color(0x4400F58D),
                      blurRadius: 30,
                      offset: Offset(10, 10),
                      spreadRadius: 0)
                ]),
                child: Image(
                  image: AssetImage("assets/logo_round.png"),
                  height: 200,
                  width: 200,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                  _signIn();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (Context) => HomeScreen()));
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
                    "Login With Email",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmailPassSignupScrenn()));
                },
                child: Text("Sign Up using Email"),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Wrap(
                  children: [
                    TextButton.icon(
                        onPressed: () {
                          _signInUsingGoogle();
                        },
                        icon: Icon(
                          FontAwesomeIcons.google,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Sign-in Using Gmail",
                          style: TextStyle(color: Colors.red),
                        )),
                    TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhoneSignInScreen()));
                        },
                        icon: Icon(Icons.phone),
                        label: Text("Sign-in Using Phone"))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((user) {
        _db.collection("user").doc(user.user.uid).set({
          "email": email,
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
                title: Text("Done"),
                content: Text("Sign In Success"),
                actions: [
                  TextButton(
                    child: Text("Cancel"),
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
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      _emailController.text = "";
                      _passwordController.text = "";
                      Navigator.of(context).pop();
                    },
                  )
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
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    _emailController.text = "";
                    _passwordController.text = "";
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  void _signInUsingGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final user =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      print("Signed in ");

      if (user != null) {
        _db.collection("users").doc(user.uid).set({
          "displayname": user.displayName,
          "email": user.email,
          "photourl": user.photoURL,
          "lastseen": DateTime.now(),
          "signin_method": user.providerData,
        });
      }
    } catch (e) {
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
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    _emailController.text = "";
                    _passwordController.text = "";
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }
}
