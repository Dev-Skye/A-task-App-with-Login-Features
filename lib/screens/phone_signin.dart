import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:login_page/config/config.dart';

class PhoneSignInScreen extends StatefulWidget {
  @override
  _PhoneSignInScreenState createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  PhoneNumber _phoneNumber;
  String _message;
  String _verificationId;
  bool _isSMSsent = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _smsController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Sign In"),
      ),
      body: SingleChildScrollView(
        child: AnimatedContainer(
          duration: Duration(
            milliseconds: 500,
          ),
          margin: EdgeInsets.only(top: 25),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: InternationalPhoneNumberInput(
                  onInputChanged: (phoneNumberTxt) {
                    _phoneNumber = phoneNumberTxt;
                  },
                  inputBorder: OutlineInputBorder(),
                ),
              ),
              _isSMSsent
                  ? Container(
                      margin: EdgeInsets.all(10),
                      child: TextField(
                        controller: _smsController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "OTP here",
                          labelText: "OTP",
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    )
                  : Container(),
              !_isSMSsent
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          _isSMSsent = true;
                        });
                        _verifyPhoneNumber();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(20)),
                        margin:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: Center(
                            child: Text(
                          "SEND OTP",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        _signInWithPhoneNumber();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(20)),
                        margin:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: Center(
                            child: Text(
                          "VERIFY OTP",
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

  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _message = 'Received phone auth credential: $phoneAuthCredential';
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        _message =
            'Phone number verification received failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber.phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: _smsController.text);

    final User user = (await _auth.signInWithCredential(credential)).user;
    final User currentUser = await _auth.currentUser;
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _db.collection("users").doc(user.uid).set({
          "phonenumber": user.phoneNumber,
          "lastseen": DateTime.now(),
          "signin_method": user.providerData,
        });
        _message = 'Successfully signed in, uid: ' + user.uid;
        print(_message);
      } else {
        _message = 'Sign in failed';
      }
    });
  }
}
