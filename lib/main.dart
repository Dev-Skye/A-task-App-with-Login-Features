import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_page/config/config.dart';
import 'package:login_page/screens/homescreen.dart';
import 'package:login_page/screens/loginscreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        primaryColor: primaryColor,
        brightness: Brightness.light,
      ),
      darkTheme:
          ThemeData(primaryColor: primaryColor, brightness: Brightness.dark),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: _auth.authStateChanges(),
          builder: (ctx, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              User user = snapshot.data;
              if (user != null) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            }
            return LoginScreen();
          }),
    );
  }
}
