import 'dart:io';
import 'package:echo_chat/api/apis.dart';
import 'package:echo_chat/helper/dialogs.dart';
import 'package:echo_chat/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:echo_chat/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isanimate = false;
  @override
  void initState() {
    super.initState();
    //future delayed function will execute after given duration.
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _isanimate = true;
      });
    });
  }

  _handlegooglesignin() {
    Dialogs.ShowProgress(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        print(user.user);
        print(user.additionalUserInfo);
        if (await Apis().userExist() == true) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await Apis().createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Apis.auth.signInWithCredential(credential);
    } catch (e) {
      print(e);
      Dialogs.showWarning(context, "Check your Internet Connection!");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Echo Chat"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(children: [
        AnimatedPositioned(
          top: mq.height * .15,
          width: mq.width * .5,
          right: _isanimate ? mq.width * .25 : -mq.width * .5,
          //If any change is applied in the position of widget,change will happen in given duration
          duration: Duration(seconds: 1),
          child: Image.asset("images/appicon.png"),
        ),
        Positioned(
          bottom: mq.height * .15,
          width: mq.width * .9,
          left: mq.width * .05,
          height: mq.height * .07,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade500,
              shape: StadiumBorder(),
            ),
            onPressed: () {
              _handlegooglesignin();
            },
            icon: Image.asset(
              "images/google.png",
              height: mq.height * .03,
            ),
            label: RichText(
              text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  children: [
                    TextSpan(text: ' Sign in with '),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w500))
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}
