import 'dart:async';
import 'package:firebase_chat/ChatList/chat_users_list.dart';
import 'package:firebase_chat/authservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_chat/Login/login.dart';
import 'package:firebase_chat/main.dart';



class InitialPage extends StatefulWidget {
  InitialPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {

  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadInitialPage();
  }

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp();
    assert(app != null);
    print('Initialized default app $app');
  }
  loadInitialPage() async {
    initializeDefault();
    Timer(Duration(seconds: 3), () {
      authService.islogedin().then((value) {
        if(value) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(
                  builder: (context) => ChatUserList()
              )
              , (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(
                  builder: (context) => Login()
              )
              , (route) => false);
        }

      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Chat Demo',
                style: TextStyle(
                  fontSize: 38,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),

            ],
          ),
        )
    );
  }
}