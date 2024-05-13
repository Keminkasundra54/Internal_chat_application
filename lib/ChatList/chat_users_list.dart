// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket socket;

class ChatUserList extends StatefulWidget {
  ChatUserList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatUserListState();
  }
}

class User {
  String name;
  String email;
  String photoUrl;
  String id;
  String googleId;
  // Other user attributes

  User(
      {required this.name,
      required this.email,
      required this.photoUrl,
      required this.id,
      required this.googleId});

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String,
        id: json['id'] as String,
        googleId: json['googleId'] as String,
      );
}

class OtherUser {
  String name; // Replace with actual properties based on received data
  String email; // Replace with actual properties based on received data
  String photoUrl; // Replace with actual properties based on received data

  OtherUser({
    required this.name,
    required this.email,
    required this.photoUrl,
  });
  factory OtherUser.fromJson(Map<String, dynamic> json) => OtherUser(
        name: json['name'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String,
      );
}

class _ChatUserListState extends State<ChatUserList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final secureStorage = new FlutterSecureStorage();

  final TextEditingController _messageTextController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool isscroolvisible = false;
  final _scrollcontroller = ScrollController();
  // DatabaseReference rootRef = FirebaseDatabase.instance.reference();
  String? uid = '';
  String? email = '';
  String? name = '';
  List<OtherUser> users = []; // List to store received users

  // var userInfo;
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // getdata();
    Future<User?> user = getdata(); // Call getdata and store the Future
    user.then((userObject) {
      if (userObject != null) {
        socket = IO.io('http://192.168.1.13:3000', <String, dynamic>{
          'transports': ['websocket'],
        });
        socket.connect();
        print('Connected to Socket.io server!');

        socket.on('connect', (_) => print('Connected'));
        socket.emit('user', userObject.email);

        // Use Completer to wait for currentUser to be set
        // Completer<User?> completer = Completer<User?>();

        socket.on('userData', (data) async {
          print(data);
          for (name in data) {
            print('User Name: $name["Name"]'); // Access each name in the list
            // You can also add names to a separate list for further processing
          }
          _handleUserData(data);
        });

        socket.on('disconnect', (_) => print('Disconnected'));
      } else {
        print('No user data retrieved.');
        // Handle the case where no data is found
      }
    });
    // Timer.periodic(Duration(seconds: 1),  (s) {
    //   print("aaaaaaa $_lastLifecycleState.");
    // });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
      if (state == AppLifecycleState.detached ||
          state == AppLifecycleState.paused) {
        print('offline');
        // FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(uid)
        //     .update({'onlineStatus': "last seen at ${DateFormat('MMM dd').add_jm().format(DateTime.now())}"});
      } else if (state == AppLifecycleState.resumed) {
        print('online');
        // FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(uid)
        //     .update({'onlineStatus': "Online"});
      }
      print("ssssss $state");
    });
  }

  // getdata() async {
  //   String? userDataString = await secureStorage.read(key: 'user');

  //   if (userDataString != null && userDataString.isNotEmpty) {
  //     try {
  //       // Attempt decoding with error handling

  //       return User.fromJson(jsonDecode(userDataString));
  //     } on FormatException catch (e) {
  //       print('Error decoding user data: $e');
  //       return null; // Handle decoding error
  //     }
  //   } else {
  //     return null; // Handle case where no data is found
  //   }
  //   // userInfo = await secureStorage.read(key: "user");
  //   // print(userInfo);
  //   // // uid = userInfo.id;
  //   // // email = userInfo.email;
  //   // // name = userInfo.name;
  //   // // print(uid);
  //   // // print(email);
  //   // // print(name);
  //   // print('ID: ${userInfo.id}');
  //   // print('Email: ${userInfo.email}');
  //   // print('Name: ${userInfo.name}');
  //   // print('ID: ${userInfo.getId()}');
  //   // print('Email: ${userInfo.getEmail()}');
  //   // print('Name: ${userInfo.getName()}');

  //   // // FirebaseFirestore.instance
  //   // //     .collection('users')
  //   // //     .doc(uid)
  //   // //     .update({'onlineStatus': "Online"});

  //   // socket = IO.io('http://192.168.1.13:3000', <String, dynamic>{
  //   //   'transports': ['websocket'],
  //   // });
  //   // socket.connect();
  //   // print('Connected to Socket.io server!');

  //   // socket.on('connect', (_) => print('Connected'));
  //   // socket.emit('user', email);

  //   // // Use Completer to wait for currentUser to be set
  //   // // Completer<User?> completer = Completer<User?>();

  //   // socket.on('userData', (data) async {
  //   //   print(data);
  //   // });

  //   // socket.on('disconnect', (_) => print('Disconnected'));
  // }

  Future<User?> getdata() async {
    String? userDataString = await secureStorage.read(key: 'user');

    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        // Attempt decoding with error handling
        return User.fromJson(jsonDecode(userDataString));
      } on FormatException catch (e) {
        print('Error decoding user data: $e');
        return null;
      }
    } else {
      print('No user data found in secure storage');
      return null;
    }
  }

  Future<void> _handleUserData(dynamic data) async {
    // Parse the data into an OtherUser object
    OtherUser otherUser = OtherUser.fromJson(jsonDecode(data));

    // Update UI with the received user data (add to user list)
    setState(() {
      users.add(otherUser);
    });
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
          return Future.value(true); // Allow back navigation
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildColumn(),
          backgroundColor: Colors.black,
        ));
  }

  // Widget _buildAppBar(BuildContext context) {
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => Profile(url: "AppBar",uid: uid!, image: '',)));
          },
          padding: EdgeInsets.only(right: 25),
        ),
      ],
      backgroundColor: Colors.white10,
    );
  }

  // Widget _buildColumn() {
  //   return Column(
  //     children: <Widget>[
  //       new Flexible(
  //         child: StreamBuilder(
  //           stream: FirebaseFirestore.instance.collection("users").snapshots(),
  //           builder: (context, snap) {
  //             // if (snap.hasData && snap.data != null) {
  //             //   // print(snap.data.documents[0]['name']);
  //             //   return  new ListView.builder(
  //             //     padding: new EdgeInsets.only(top:8.0,bottom: 8),
  //             //     // reverse: true,
  //             //     itemBuilder: (_, int index) => buildCard(snap.data.documents[index]),
  //             //     itemCount: snap.data.documents.length,
  //             //   );
  //             // }
  //              if (snap.hasData && snap.data != null) {
  //             return ListView.builder(
  //               padding: EdgeInsets.only(top: 8.0, bottom: 8),
  //               itemBuilder: (_, int index) {
  //                 var documents = snap.data!.docs;
  //                 if (documents != null && index < documents.length) {
  //                   return buildCard(documents[index]);
  //                 } else {
  //                   return SizedBox();
  //                 }
  //               },
  //               itemCount: snap.data!.docs.length,
  //             );
  //           }
  //             else
  //               return Center(
  //                 child: Container(
  //                   child: Text("No Users Available",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600),),
  //                 ),
  //               );
  //           },
  //         ),),
  //     ],
  //   );
  // }
  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        new Flexible(
          child: Container(
            // Wrap with Container to handle height properly
            child: ListView.builder(
              controller: _scrollcontroller,
              itemBuilder: (_, int index) {
                // return null;
                OtherUser user = users[index];
                return buildCard(user);
                // Implement your logic for building list items
              },
              itemCount: 0, // Change this to the actual item count
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCard(data) {
    return data['uid'] != uid
        ? Container(
            decoration: BoxDecoration(
              // color: Colors.white10,
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            margin: EdgeInsets.only(top: 7),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              tileColor: Colors.white10,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) =>
                //       ChatScreen(Code: data['uid'],Name: data['name'],Photo: data['photoUrl'],senderName:  name!,senderUid: uid!,senderEmail: data['email'],),),
                // );
              },
              title: Container(
                margin: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                        width: 55.0,
                        height: 55.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black12,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(data['photoUrl'])))),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              data['name'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 200,
                            child: Text(
                              data['email'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox();
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
