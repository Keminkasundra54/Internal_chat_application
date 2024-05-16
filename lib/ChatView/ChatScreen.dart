import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui';

import 'package:firebase_chat/ChatView/full_photo.dart';
import 'package:firebase_chat/ChatView/user_detail.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket socket;
List<dynamic> messages = []; // Change data to messages

class ChatScreen extends StatefulWidget {
  String Code;
  String Name;
  String Photo;
  String senderName;
  String senderUid;
  String senderEmail;
  ChatScreen(
      {Key? key,
      required this.Code,
      required this.Name,
      required this.Photo,
      required this.senderName,
      required this.senderUid,
      required this.senderEmail})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
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
        name: json['name'] as String ?? '',
        email: json['email'] as String ?? '',
        photoUrl: json['photoUrl'] as String ?? '',
        id: json['id'] as String ?? '',
        googleId: json['googleId'] as String ?? '',
      );
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageTextController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool isscroolvisible = false;
// DatabaseReference rootRef = FirebaseDatabase.instance.reference();
  String? groupChatId;
  String? peerId;
  String? peerAvatar;
  String? peerName;
  String? id;
  final secureStorage = new FlutterSecureStorage();
  File? imageFile;
  bool isLoading = false;
  String? imageUrl;
  int _limit = 20;
  final int _limitIncrement = 20;
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // final String senderName = widget.senderName;

    groupChatId = '';
    listScrollController.addListener(_scrollListener);
    // print(senderName);

    readLocal();
    // rootRef.child(widget.Code).onChildRemoved
    //     .listen((event) {
    //   rootRef.child(widget.Code).remove();
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) =>
    //         Login()),
    //   );
    // });
    super.initState();
  }

  @override
  void dispose() {
    _messageTextController.dispose();

    socket.off('messagesData');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.detached ||
          state == AppLifecycleState.paused) {
        print('offline');
        // FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(widget.senderUid)
        //     .update({
        //   'onlineStatus':
        //       "last seen at ${DateFormat('MMM dd').add_jm().format(DateTime.now())}"
        // });
      } else if (state == AppLifecycleState.resumed) {
        print('online');
        // FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(widget.senderUid)
        //     .update({'onlineStatus': "Online"});
      }
      print("ssssss $state");
    });
  }

  readLocal() async {
    peerId = widget.Code;
    peerAvatar = widget.Photo;
    peerName = widget.Name;
    print('emaaaaiillllllllllllll');
    print(widget.senderEmail);
    print(widget.Code);
    print(widget.Name);
    print(widget.Photo);
    // print(widget.senderName);
    // print(widget.senderUid);
    // id = ''; // Fetch user id from your authentication system or storage
    // Your socket.io logic for reading local data
    String? userDataString = await secureStorage.read(key: 'user');
    print(userDataString);
    // if (messages.isEmpty) {
    // If no messages are available, clear the messages list
    setState(() {
      messages = [];
    });
    // }
    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        // Attempt decoding with error handling
        print(userDataString);

        var user = User.fromJson(jsonDecode(userDataString));
        print("user data: $user");
        id = user.id;
        // return user;
      } on FormatException catch (e) {
        print('Error decoding user data: $e');
      }
    } else {
      print('No user data found in secure storage');
    }
    // id = await secureStorage.read(key: "id") ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    // // FirebaseFirestore.instance
    // //     .collection('users')
    // //     .doc(id)
    // //     .update({'chattingWith': peerId});

    // setState(() {});
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    socket = IO.io('http://192.168.1.13:3000', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.connect();
    print('Connected to Socket.io server!');

    socket.on('connect', (_) => print('Connected'));
    // Emit the 'send_message' event with the message object
    print(id);
    if (id != "" && peerId != "") {
      var message = {
        'idFrom': id,
        'idTo': peerId,
      };
      socket.emit('getchatmsg', message);
    }

    // socket.on('messagesData ', (data) async {
    //   print('Received message: $data');
    //   // Handle the received message here, such as updating UI or storing in a list
    // });
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(true);
        },
        child: Scaffold(
          appBar: _buildAppBar(context, socket),
          body: _buildColumn(socket),
          backgroundColor: Colors.black,
        ));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, IO.Socket socket) {
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      title: Hero(
        tag: "AppBar",
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetails(
                    url: "AppBar",
                    image: widget.Photo,
                    uid: widget.Code,
                  ),
                ),
              ).then((value) {
                print('value $value');
                // print("assssss");
                // setState(() {});
              });
            },
            child: Row(
              children: [
                Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black12,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.Photo),
                    ),
                  ),
                ),
                // StreamBuilder<dynamic>(
                //   // stream: FirebaseFirestore.instance
                //   //     .collection("users")
                //   //     .where("uid", isEqualTo: widget.Code)
                //   //     .snapshots(),
                //   // stream: socket.on('messagesData'),
                //   // stream: socket.on('userData',(_)=>{
                //   //   print("user data"),

                //   // }) // Listen for 'user_data' event

                //   builder: (context, snapshot) {
                //     if (snapshot.hasError) {
                //       return Text('Error: ${snapshot.error}'); // Handle errors
                //     }

                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return SizedBox(); // Show placeholder while waiting
                //     }

                //     // Safe access to documents using null-safe operator
                //     final data = snapshot.data?.docs;

                //     if (data?.isNotEmpty == true) {
                //       final userDoc =
                //           data![0]; // Access the first document safely
                //       final name = userDoc['name'];
                //       final onlineStatus = userDoc['onlineStatus'];

                //       return Container(
                //         padding: EdgeInsets.only(left: 15),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               name ?? "", // Handle potential null value of name
                //               style:
                //                   TextStyle(fontSize: 16, color: Colors.white),
                //             ),
                //             onlineStatus?.isNotEmpty ==
                //                     true // Check if onlineStatus exists
                //                 ? Text(
                //                     onlineStatus,
                //                     style: TextStyle(
                //                         fontSize: 12, color: Colors.white),
                //                   )
                //                 : SizedBox(),
                //           ],
                //         ),
                //       );
                //     } else {
                //       return SizedBox(); // Handle no data case
                //     }
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
      // title: Text('Your Title Here'), // Replace with your title

      backgroundColor: Colors.white10,
    );
  }

//   Widget _buildColumn() {
//     return Column(
//       children: <Widget>[
//         new Flexible(
//           child: StreamBuilder(
//             stream: FirebaseFirestore.instance
//                 .collection('messages')
//                 .doc(groupChatId)
//                 .collection(groupChatId)
//                 .orderBy('timestamp', descending: true)
//                 .snapshots(),
//             builder: (context, snap) {
//               if (snap.hasData) {
//                 return new ListView.builder(
//                   padding: new EdgeInsets.all(8.0),
//                   reverse: true,
//                   itemBuilder: (_, int index) =>
//                       message(snap.data.documents[index]),
//                   itemCount: snap.data.documents.length,
//                   controller: listScrollController,
//                 );
//               } else
//                 return Center(
//                   child: Container(),
//                 );
//             },
//           ),
//         ),
//         // StreamBuilder(
//         //   stream: rootRef.child("typing").onValue,
//         //   builder: (context, snap) {
//         //     if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {
//         //       Map data = snap.data.snapshot.value;
//         //       print(data["name"]);
//         //       return data["name"] != widget.Name && data["name"] != '' ? Container(
//         //         padding: EdgeInsets.only(left: 20),
//         //         alignment: Alignment.centerLeft,
//         //         child: Text(data["name"].toString() + " is typing..",style: TextStyle(color: Colors.white),),
//         //       ) : SizedBox();
//         //     }
//         //     else
//         //       return Center(
//         //         child: Container(),
//         //       );
//         //   },
//         // ),
//         Padding(padding: EdgeInsets.only(top: 10)),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width - 100,
//               margin: EdgeInsets.only(bottom: 2),
//               child: Material(
//                 elevation: 5.0,
//                 borderRadius: BorderRadius.circular(30),
//                 child: new TextField(
//                   textCapitalization: TextCapitalization.sentences,
//                   controller: _messageTextController,
//                   minLines: 1,
//                   maxLines: 3,
//                   onChanged: (text) {
//                     // if (text != '') {
//                     //   rootRef.child(widget.Code).child("typing").update({
//                     //     "name" : widget.Name
//                     //   });
//                     // } else {
//                     //   rootRef.child(widget.Code).child("typing").update({
//                     //     "name" : ''
//                     //   });
//                     // }
//                     // print(text);
//                   },
//                   decoration: new InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide:
//                             BorderSide(width: 0, style: BorderStyle.none),
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: EdgeInsets.all(12),
//                       suffixIcon: IconButton(
//                         icon: Icon(Icons.image),
//                         onPressed: () {
//                           filePicker(context, 'image');
//                         },
//                         color: Colors.grey,
//                       ),
//                       hintText: "Type here...",
//                       hintStyle: TextStyle(
//                           fontFamily: 'Nunito',
//                           color: HexColor.fromHex('#C5C5C5'),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500)),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () async {
//                 // _publishMessage(_messageTextController.text);
//                 onSendMessage(_messageTextController.text, 0);
//               },
//               child: ClipOval(
//                 child: Container(
//                   child: Material(
//                     elevation: 5,
//                     child: Ink(
//                       padding: EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                               colors: [
//                                 Colors.deepPurple,
//                                 Colors.deepOrangeAccent
//                               ],
//                               begin: const FractionalOffset(0.0, 0.0),
//                               end: const FractionalOffset(1.3, 1.0),
//                               stops: [0.0, 1.0],
//                               tileMode: TileMode.clamp),
//                           borderRadius: BorderRadius.circular(50.0)),
// //                      splashColor: Colors.blue, // inkwell color
//                       child: Icon(
//                         Icons.send,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Padding(padding: EdgeInsets.only(top: 10)),
//       ],
//     );
//   }

  Widget _buildColumn(IO.Socket socket) {
    // socket.on('messagesData', (data) async {
    //   print('Received message data: $data');
    //   print(data.runtimeType); // Print data
    //   setState(() {
    //     messages = data;
    //   });
    // });
    socket.on('messagesData', (data) async {
      // print('Received message data: $data');
      if (mounted) {
        setState(() {
          messages = [];
          messages = data.reversed.toList();
          // print('messages: $messages'); // Update messages
          // print('Updated messages: $messages'); // Print updated messages
        });
      }
    });
    // print('messages: $messages');
    return Column(
      children: <Widget>[
        // Flexible(
        //   child: StreamBuilder<dynamic>(
        //     stream: null,
        //     builder: (context, snap) {
        //       // if (snap.hasError) {
        //       //   return Text('Error: ${snap.error}'); // Handle errors
        //       // }

        //       // if (snap.connectionState == ConnectionState.waiting) {
        //       //   return Center(
        //       //       child:
        //       //           CircularProgressIndicator()); // Show loading indicator
        //       // }

        //       // Safe access to documents using null-safe operator
        //       // final data = snap.data?.docs;

        //       if (data?.isNotEmpty == true) {
        //         return ListView.builder(
        //           padding: EdgeInsets.all(8.0),
        //           reverse: true,
        //           itemCount: data!
        //               .length, // Use data! here as it's not null after the check
        //           // controller: listScrollController,
        //           itemBuilder: (_, int index) => message(data[index]),
        //         );
        //       } else {
        //         return SizedBox(); // Handle no data case
        //       }
        //     },
        //   ),
        // ),
        // Flexible(
        //   child: ListView.builder(
        //       // Implement your chat list here
        //       // Replace this with your chat list implementation
        //       itemBuilder: (context, index) {
        //         return ListTile(
        //           title: Text('Chat Message $index'),
        //         );
        //       },
        //       itemCount: 20,
        //       controller: listScrollController),
        // ),
        // Flexible(
        //         child: messages.isEmpty
        //             ? Center(child: Text('No messages yet'))
        //             : ListView.builder(
        //                 padding: EdgeInsets.all(8.0),
        //                 reverse: true,
        //                 itemCount: messages.length,
        //                 controller: listScrollController,
        //                 itemBuilder: (_, int index) {
        //                   // Build message widgets here
        //                 },
        //               ),
        //       ),

        Flexible(
          child: messages.isEmpty
              ? Center(child: Text('No messages yet'))
              : ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: messages.length,
                  controller: listScrollController,
                  itemBuilder: (_, int index) {
                    // final message = messages[index];
                    // print('Message at index $index: $message');
                    // return message(message);
                    // print(index);
                    // print(messages.length);
                    if (index < messages.length) {
                      final messagess = messages[index];
                      if (messagess != null) {
                        return message(messagess);
                        // print('Message at index $index: $messagess');
                      } else {
                        // Handle null message (e.g., print message or return empty container)
                        return Center(child: Text('No messages yet'));
                      }
                    } else {
                      return Container(); // Handle potential out-of-bounds index
                    }
                  },
                ),
        ),

        Padding(padding: EdgeInsets.only(top: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 100,
              margin: EdgeInsets.only(bottom: 2),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _messageTextController,
                  minLines: 1,
                  maxLines: 3,
                  onChanged: (text) {
                    // Your logic here
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(12),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () => {filePicker(context, 'image')},
                      color: Colors.grey,
                    ),
                    hintText: "Type here...",
                    hintStyle: TextStyle(
                      fontFamily: 'Nunito',
                      color: HexColor.fromHex('#C5C5C5'),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final message = _messageTextController.text;
                if (message.isNotEmpty) {
                  onSendMessage(message, 0); // Ensure message is not empty
                }
              },
              child: ClipOval(
                child: Container(
                  child: Material(
                    elevation: 5,
                    child: Ink(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepOrangeAccent],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.3, 1.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp,
                        ),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 10)),
      ],
    );
  }

// deleteMessage(data) {
//   return showModalBottomSheet<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//             child: new Wrap(children: <Widget>[
//           new ListTile(
//               leading: new Icon(Icons.delete),
//               title: new Text('Delete'),
//               onTap: () async {
//                 await FirebaseFirestore.instance
//                     .runTransaction((Transaction myTransaction) async {
//                   await myTransaction.delete(data.reference);
//                 }).then((value) => Navigator.pop(context));
//               }),
//         ]));
//       });
// }
  deleteMessage(data) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: new Wrap(children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.delete),
              title: new Text('Delete'),
              onTap: () async {
                // await firestore.FirebaseFirestore.instance.runTransaction(
                //     (firestore.Transaction myTransaction) async {
                //   await myTransaction.delete(data.reference);
                // }).then((value) => Navigator.pop(context));
              },
            ),
          ]),
        );
      },
    );
  }

  Widget message(data) {
    final bool isCurrentUserMessage = data['idFrom'] == peerId;
    return isCurrentUserMessage
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          data['type'] == 1
                              // Image
                              ? GestureDetector(
                                  onLongPress: () async {
                                    deleteMessage(data);
                                    // print(data['content']);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: TextButton(
                                      child: Hero(
                                        tag: 'Photo',
                                        child: Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.deepPurple),
                                              ),
                                              width: 200.0,
                                              height: 200.0,
                                              padding: EdgeInsets.all(70.0),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Material(
                                              child: Image.asset(
                                                'images/img_not_available.jpeg',
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                            ),
                                            imageUrl: data['content'],
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FullPhoto(
                                                      url: data['content'],
                                                      showEdit: true,
                                                      uid: '',
                                                    )));
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.all(0),
                                      ),
                                    ),
                                  ))
                              : GestureDetector(
                                  onLongPress: () async {
                                    deleteMessage(data);
                                    // await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                                    //   await myTransaction.delete(data.reference);
                                    // });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 10.0, left: 90),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.deepPurple,
                                              Colors.white38
                                            ],
                                            begin: const FractionalOffset(
                                                0.0, 0.0),
                                            end: const FractionalOffset(
                                                1.2, 1.0),
                                            stops: [0.0, 1.0],
                                            tileMode: TileMode.clamp),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            topLeft: Radius.circular(19))),
                                    child: Column(
                                      children: <Widget>[
                                        Stack(
                                          children: <Widget>[
                                            new Container(
                                              margin: const EdgeInsets.only(
                                                  top: 12,
                                                  left: 12,
                                                  right: 35,
                                                  bottom: 12),
                                              child: new Text(
                                                data['content'].toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          data['type'] == 1
                              // Image
                              ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: TextButton(
                                    child: Hero(
                                      tag: '${data['content']}',
                                      child: Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.deepPurple),
                                            ),
                                            width: 200.0,
                                            height: 200.0,
                                            padding: EdgeInsets.all(70.0),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            child: Image.asset(
                                              'images/img_not_available.jpeg',
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          imageUrl: data['content'],
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FullPhoto(
                                                    url: data['content'],
                                                    showEdit: true,
                                                    uid: '',
                                                  )));
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.all(0),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 90.0, left: 10),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.white38,
                                              Colors.black38
                                            ],
//                    begin: Alignment.topLeft,
//                    end: Alignment.bottomRight,
                                            begin: const FractionalOffset(
                                                0.0, 0.0),
                                            end: const FractionalOffset(
                                                1.2, 1.0),
                                            stops: [0.0, 1.0],
                                            tileMode: TileMode.clamp),
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            topLeft: Radius.circular(19))),
                                    child: Column(
                                      children: <Widget>[
                                        Stack(
                                          children: <Widget>[
                                            new Container(
                                              margin: const EdgeInsets.only(
                                                  top: 12,
                                                  left: 12,
                                                  right: 35,
                                                  bottom: 12),
                                              child: new Text(
                                                data['content'].toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            // Positioned(
                                            //   top: 5,left: 12,
                                            //   child: Container(
                                            //     child: new Text(data['Sender'].toString(),style: TextStyle(fontSize: 11,color: Colors.white),),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  void _publishMessage(String text) {
    if (text != '') {
      print(widget.Name);
      // var newkey = rootRef.child("Messages").push().key;
      String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
      DateTime now = DateTime.now();
      String time = new DateFormat.jm().format(now);
      // rootRef.child("Messages").child(newkey!).set({
      //   "Sender": widget.senderName,
      //   "SenderCode": widget.senderUid,
      //   "Code": widget.Code,
      //   "Message": text.trim(),
      //   "created": int.parse(timestamp()),
      //   "Time": "$time",
      // });
      _messageTextController.clear();
      // rootRef.child(widget.Code).child("typing").update({
      //   "name" : ''
      // });
    }
  }

// Future uploadFile(file, fileType) async {
//   String Url;
//   String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//   StorageReference reference;
//   if (fileType == 1) {
//     reference = FirebaseStorage.instance.ref().child('images/$fileName');
//   } else if (fileType == 2) {
//     reference = FirebaseStorage.instance.ref().child('audios/$fileName');
//   } else if (fileType == 3) {
//     reference = FirebaseStorage.instance.ref().child('videos/$fileName');
//   } else if (fileType == 4) {
//     reference = FirebaseStorage.instance.ref().child('documents/$fileName');
//   }
//   StorageUploadTask uploadTask = reference.putFile(file);
//   StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
//   storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
//     Url = downloadUrl;
//     print(downloadUrl);
//     setState(() {
//       isLoading = false;
//       onSendMessage(Url, fileType);
//     });
//   }, onError: (err) {
//     setState(() {
//       isLoading = false;
//     });
//   });
// }

  Future<void> uploadFile(File file) async {
    // String url;
    // String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final bytes = await file.readAsBytes();

    // Replace with your server address
    socket.emit('upload', {
      'fileName': p.basename(file.path!),
      'fileData': bytes,
      // 'fileType': fileType, // Add this line if sending fileType
    });
// StorageReference storageRef;

// try {
//   // Create a reference based on fileType
//   switch (fileType) {
//     case 1:
//       storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
//       break;
//     case 2:
//       storageRef = FirebaseStorage.instance.ref().child('audios/$fileName');
//       break;
//     case 3:
//       storageRef = FirebaseStorage.instance.ref().child('videos/$fileName');
//       break;
//     case 4:
//       storageRef = FirebaseStorage.instance.ref().child('documents/$fileName');
//       break;
//     default:
//       print('Invalid file type: $fileType');
//       return;  // Handle invalid file type
//   }

//   // Upload the file
//   final uploadTask = storageRef.putFile(file);
//   final storageTaskSnapshot = await uploadTask.onComplete;
//   url = await storageTaskSnapshot.ref.getDownloadURL();

//   print(url);
//   setState(() {
//     isLoading = false;
//     onSendMessage(url, fileType);
//   });
// } catch (e) {
//   print('Error uploading file: $e');
//   setState(() {
//     isLoading = false;
//   });
// }
  }

// Future getImage() async {
//   ImagePicker imagePicker = ImagePicker();
//   PickedFile pickedFile;

//   pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
//   imageFile = File(pickedFile.path);

//   setState(() {
//     isLoading = true;
//   });
//   uploadFile(imageFile, 1);
// }
  Future<void> getImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        setState(() {
          isLoading = true;
        });
        uploadFile(imageFile); // Assuming uploadFile handles file type
      } else {
        print('User canceled image selection');
      }
    } on PlatformException catch (e) {
      // Handle platform exceptions (e.g., permission errors)
      print('Error picking image: $e');
    }
  }

// Future filePicker(BuildContext context, fileType) async {
//   File file;
//   String fileName;
//   try {
//     if (fileType == 'image') {
//       file = await FilePicker.getFile(type: FileType.IMAGE);
//       setState(() {
//         fileName = p.basename(file.path);
//       });
//       print(fileName);
//       uploadFile(file, 1);
//     }
//     if (fileType == 'image') {
//       final result = await FilePicker.pickFiles(type: FileType.IMAGE);
//       if (result != null) {
//         file = result.first; // Assuming you want the first selected file
//         fileName = p.basename(file.path);
//         setState(() {
//           fileName = fileName;
//         });
//         print(fileName);
//         uploadFile(file, 1);
//       }
//     }
//     if (fileType == 'audio') {
//       file = await FilePicker.getFile(type: FileType.AUDIO);
//       fileName = p.basename(file.path);
//       setState(() {
//         fileName = p.basename(file.path);
//       });
//       print(fileName);
//       uploadFile(file, 2);
//     }
//     if (fileType == 'video') {
//       file = await FilePicker.getFile(type: FileType.VIDEO);
//       fileName = p.basename(file.path);
//       setState(() {
//         fileName = p.basename(file.path);
//       });
//       print(fileName);
//       uploadFile(file, 3);
//     }
//     if (fileType == 'pdf' || fileType == 'others') {
//       file = await FilePicker.getFile(
//           type: FileType.CUSTOM, fileExtension: 'pdf');
//       fileName = p.basename(file.path);
//       setState(() {
//         fileName = p.basename(file.path);
//       });
//       print(fileName);
//       uploadFile(file, 4);
//     }
//   } on PlatformException catch (e) {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Sorry...'),
//             content: Text('Unsupported exception: $e'),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               )
//             ],
//           );
//         });
//   }
// }
  Future<void> filePicker(BuildContext context, String fileType) async {
    PlatformFile? platformFile;
    String fileName = '';
    try {
      // Check if FileType is imported
      if (FileType.values == null) {
        throw Exception('Missing FileType import from file_picker package');
      }

      final fileTypeValue = _getFileTypeFromName(fileType);
      if (fileTypeValue == null) {
        print('Invalid file type: $fileType');
        return; // Handle invalid file type
      }

      // final result = await FilePicker.platform.pickFiles(type: fileTypeValue);
      final result = await FilePicker.platform.pickFiles(type: fileTypeValue);
      if (result != null && result.files.isNotEmpty) {
        platformFile = result.files.first;
        print(platformFile);
        print(platformFile.path);
        if (platformFile?.path != null) {
          print(platformFile.path);
          fileName = p.basename(platformFile.path!);
          // ... rest of your code using the path
        } else {
          print('Path is not available');
          // Handle the case where the path is not accessible (optional)
        }

        // fileName = p.basename(platformFile.path!);
        setState(() {
          fileName =
              fileName; // Assuming you want to update the UI with the filename
        });
        print(fileName);
        //  File file = File(platformFile.path!);
        File file = File.fromUri(Uri.file(platformFile.path!));

        uploadFile(file); // Assuming uploadFile handles file type
      }
    } on PlatformException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Unsupported exception: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    }
  }

  // Future<void> filePicker(BuildContext context, int fileType) async {
  //   PlatformFile? platformFile;
  //   String fileName = '';
  //   FileType fileTypeValue;
  //   switch (fileType) {
  //     case 0:
  //       fileTypeValue = FileType.image;
  //       break;
  //     case 1:
  //       fileTypeValue = FileType.audio;
  //       break;
  //     case 2:
  //       fileTypeValue = FileType.video;
  //       break;
  //     // Add more cases as needed for other file types
  //     default:
  //       throw ArgumentError('Invalid fileType: $fileType');
  //   }
  //   try {
  //     final result = await FilePicker.platform.pickFiles(type: fileTypeValue);
  //     if (result != null && result.files.isNotEmpty) {
  //       platformFile = result.files.first;
  //       fileName = p.basename(platformFile.path!);
  //       setState(() {
  //         fileName = fileName;
  //       });
  //       print(fileName);

  //       // Convert PlatformFile to File
  //       File file = File.fromUri(Uri.file(platformFile.path!));

  //       uploadFile(file, fileType); // Now, you're passing a File
  //     }
  //   } on PlatformException catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Error'),
  //           content: Text('Unsupported exception: $e'),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text('OK'),
  //               onPressed: () => Navigator.of(context).pop(),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  FileType? _getFileTypeFromName(String name) {
    switch (name.toLowerCase()) {
      case "image":
        return FileType.image;
      case "audio":
        return FileType.audio;
      case "video":
        return FileType.video;
      case "pdf":
        return FileType.custom; // Assuming you set file extension for PDF
      // Add cases for other supported file types
      default:
        return null;
    }
  }

//   void onSendMessage(String content, int type) {
//     // type: 0 = text, 1 = image, 2 = audio, 3 = video, 4 = others and pdf
//     if (content.trim() != '') {
//       _messageTextController.clear();

//       var documentReference = FirebaseFirestore.instance
//           .collection('messages')
//           .doc(groupChatId)
//           .collection(groupChatId!)
//           .doc(DateTime.now().millisecondsSinceEpoch.toString());

//       FirebaseFirestore.instance.runTransaction((transaction) async {
//         transaction.set(
//           documentReference,
//           {
//             'idFrom': id,
//             'idTo': peerId,
//             'Sender': widget.senderName,
//             'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
//             'content': content,
//             'type': type
//           },
//         );
//       });
//       listScrollController.animateTo(0.0,
//           duration: Duration(milliseconds: 300), curve: Curves.easeOut);
//     } else {}
//   }
// }
  void onSendMessage(String content, int type) {
    // Validate content to avoid sending empty messages
    if (content.trim() != '') {
      // Create a message object with relevant data
      Map<String, dynamic> message = {
        'idFrom': peerId,
        'idTo': id,
        // 'Sender': widget.Name,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type,
      };
      socket = IO.io('http://192.168.1.13:3000', <String, dynamic>{
        'transports': ['websocket'],
      });
      socket.connect();
      print('Connected to Socket.io server!');

      socket.on('connect', (_) => print('Connected'));
      // Emit the 'send_message' event with the message object
      socket.emit('chat_message', message);

      socket.on('disconnect', (_) => print('Disconnected'));
      // Clear the message text controller
      _messageTextController.clear();

      // Optionally animate the message list scroll to the bottom
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {}
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
