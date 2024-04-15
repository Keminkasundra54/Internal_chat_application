import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/ChatList/chat_users_list.dart';
import 'package:firebase_chat/authservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_chat/ChatView/ChatScreen.dart';
import 'package:firebase_chat/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatelessWidget {
  DatabaseReference rootRef = FirebaseDatabase.instance.reference();
  ValueNotifier<bool> Loader = ValueNotifier(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _controllername = new TextEditingController();
  TextEditingController _controllercode = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp();
    assert(app != null);
    print('Initialized default app $app');
  }
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive',
    ],
  );
  // FirebaseAuth auth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body:

      ValueListenableBuilder<bool>(
       valueListenable:  Loader,
        builder: (context, Loader, child) {
          return Loader ? Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurple,),) : SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 50),
                    child: Text("ChatDemo",style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          // Container(
                          //   padding: EdgeInsets.symmetric(horizontal: 20),
                          //   margin: EdgeInsets.only(bottom: 5),
                          //   child: TextFormField(
                          //     style: TextStyle(color: Colors.white),
                          //     decoration: InputDecoration(
                          //         focusedBorder:OutlineInputBorder(
                          //           borderSide: const BorderSide(color: Colors.white, width: 1.5),
                          //           borderRadius: BorderRadius.circular(7.0),
                          //         ),
                          //         border:OutlineInputBorder(
                          //           borderSide: const BorderSide(color: Colors.white, width: 1.5),
                          //           borderRadius: BorderRadius.circular(7.0),
                          //         ),
                          //         contentPadding: const EdgeInsets.only(left: 10, bottom: 0, top: 0, right: 0),
                          //         labelText: "Email",
                          //         labelStyle: TextStyle(
                          //             color: Colors.white
                          //         )
                          //     ),
                          //     controller: _controllername,
                          //     keyboardType: TextInputType.emailAddress,
                          //     validator: (value) {
                          //       if (value.trim().isEmpty) {
                          //         return 'Please enter email';
                          //       }
                          //       return null;
                          //     },
                          //   ),
                          // ),
                          //
                          // Container(
                          //   padding: EdgeInsets.symmetric(horizontal: 20),
                          //   margin: EdgeInsets.only(bottom: 5),
                          //   child: TextFormField(
                          //     style: TextStyle(color: Colors.white),
                          //     decoration: InputDecoration(
                          //         focusedBorder:OutlineInputBorder(
                          //           borderSide: const BorderSide(color: Colors.white, width: 1.5),
                          //           borderRadius: BorderRadius.circular(7.0),
                          //         ),
                          //         border:OutlineInputBorder(
                          //           borderSide: const BorderSide(color: Colors.white, width: 1.5),
                          //           borderRadius: BorderRadius.circular(7.0),
                          //         ),
                          //         contentPadding: const EdgeInsets.only(left: 10, bottom: 0, top: 0, right: 0),
                          //         labelText: "Password",
                          //         labelStyle: TextStyle(
                          //             color: Colors.white
                          //         )
                          //     ),
                          //     controller: _controllercode,
                          //     keyboardType: TextInputType.text,
                          //     validator: (value) {
                          //       if (value.trim().isEmpty) {
                          //         return 'Please enter password';
                          //       }
                          //       return null;
                          //     },
                          //   ),
                          // ),
                          // SizedBox(height: 10,),


                          Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            height: 44,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Colors.deepPurple,
                                child: Text(
                                  'Google SignIn',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins'),
                                ),
                                onPressed: () async {
                                  initializeDefault();
                                  await authService.googleSignin(context).then((value) {
                                    if (value!= null) {
                                      Navigator.pushAndRemoveUntil(context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatUserList()
                                          )
                                          , (route) => false);
                                    } else {
                                      showInSnackBar("Opps Something went wrong!!");
                                    }

                                  });
                                }
                            ),
                          ),
                          // Container(
                          //   margin: EdgeInsets.only(top: 20),
                          //   padding: EdgeInsets.symmetric(horizontal: 40),
                          //   height: 44,
                          //   child: RaisedButton(
                          //       shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(10)),
                          //       color: Colors.deepPurple,
                          //       child: Text(
                          //         'Sign Out',
                          //         style: TextStyle(
                          //             color: Colors.white,
                          //             fontSize: 14,
                          //             fontWeight: FontWeight.w700,
                          //             fontFamily: 'Poppins'),
                          //       ),
                          //       onPressed: () {
                          //         authService.googleSignout();
                          //       }
                          //   ),
                          // ),
                        ],
                      ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future < User > signUp(email, password) async {
    try {
     User user;
     FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: email).then((value) {
        print(value.user.displayName);
        user = value.user;
      });
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> _configureAndConnect(context) async {
  Loader.value = true;
  var newkey = rootRef.child(_controllercode.text).push().key;
  rootRef.child(_controllercode.text).child("Members").child(newkey).set({
  "member" : _controllername.text,
  }).then((value) {
  Loader.value = false;

});
  }
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value,style: TextStyle(color: Colors.white),),backgroundColor: Colors.deepPurple,));
  }
}