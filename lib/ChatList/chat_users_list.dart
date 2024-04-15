import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/ChatView/ChatScreen.dart';
import 'package:firebase_chat/Profile/profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_chat/Login/login.dart';



class ChatUserList extends StatefulWidget {
  ChatUserList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatUserListState();
  }
}

class _ChatUserListState extends State<ChatUserList> with TickerProviderStateMixin,WidgetsBindingObserver {
    final secureStorage = new FlutterSecureStorage();

  final TextEditingController _messageTextController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool isscroolvisible = false;
  final _scrollcontroller = ScrollController();
  DatabaseReference rootRef = FirebaseDatabase.instance.reference();
  String uid ='';
  String email ='';
  String name = '';
  AppLifecycleState _lastLifecycleState;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getdata();
    // Timer.periodic(Duration(seconds: 1),  (s) {
    //   print("aaaaaaa $_lastLifecycleState.");
    // });
    super.initState();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
      if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
        print('offline');
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'onlineStatus': "last seen at ${DateFormat('MMM dd').add_jm().format(DateTime.now())}"});
      } else if (state == AppLifecycleState.resumed){
        print('online');
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'onlineStatus': "Online"});
      }
      print("ssssss $state");
    });
  }
  getdata()async {
    uid = await secureStorage.read(key: "id");
    email = await secureStorage.read(key: "email");
    name = await secureStorage.read(key: "name");
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'onlineStatus': "Online"});
  }
  @override
  void dispose() {
    _messageTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () {
          SystemNavigator.pop();
        },
        child:
        Scaffold(appBar: _buildAppBar(context), body: _buildColumn(),backgroundColor: Colors.black,));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Chats"),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.account_circle), onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profile(url: "AppBar",uid: uid,)));
        },padding: EdgeInsets.only(right: 25),),

      ],
      backgroundColor: Colors.white10,
    );
  }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        new Flexible(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").snapshots(),
            builder: (context, snap) {
              if (snap.hasData) {
                // print(snap.data.documents[0]['name']);
                return  new ListView.builder(
                  padding: new EdgeInsets.only(top:8.0,bottom: 8),
                  // reverse: true,
                  itemBuilder: (_, int index) => buildCard(snap.data.documents[index]),
                  itemCount: snap.data.documents.length,
                );
              }
              else
                return Center(
                  child: Container(
                    child: Text("No Users Available",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600),),
                  ),
                );
            },
          ),),
      ],
    );
  }

  Widget buildCard (data) {
    return data['uid'] != uid ? Container(
      decoration: BoxDecoration(
        // color: Colors.white10,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      margin: EdgeInsets.only(top: 7),
      child:
      ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0)),
        tileColor: Colors.white10,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                ChatScreen(Code: data['uid'],Name: data['name'],Photo: data['photoUrl'],senderName:  name,senderUid: uid,senderEmail: data['email'],),),
          );
        },
        title: Container(
          margin: EdgeInsets.all(12),
          child:  Row(
            children: [
              Container(
                  width: 55.0,
                  height: 55.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape
                          .circle,
                      color: Colors
                          .black12,
                      image: new DecorationImage(
                          fit: BoxFit
                              .cover,
                          image: NetworkImage(
                              data['photoUrl'])))),
              Container(
                margin: EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(data['name'],style: TextStyle(color: Colors.white,fontSize: 16),),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 200,
                      child: Text(data['email'],style: TextStyle(color: Colors.white,fontSize: 16),),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),

    ) : SizedBox();
  }

}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}