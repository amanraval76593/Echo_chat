// ignore_for_file: unused_import

import 'package:echo_chat/screens/auth/login_screen.dart';
import 'package:echo_chat/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:echo_chat/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
    //future delayed function will execute after given duration.
    Future.delayed(Duration(seconds: 2), () {
      if (Apis.auth.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        Positioned(
            top: mq.height * .15,
            right: mq.width * .29,
            child: Text(
              "Echo Chat",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
            )),
        Positioned(
          top: mq.height * .25,
          width: mq.width * .5,
          right: mq.width * .25,
          //If any change is applied in the position of widget,change will happen in given duration
          child: Image.asset("images/appicon.png"),
        ),
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: SpinKitWave(
              size: 50,
              color: Colors.black,
            )),
      ]),
    );
  }
}
