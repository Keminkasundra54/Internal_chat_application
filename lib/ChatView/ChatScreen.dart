import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat/ChatView/full_photo.dart';
import 'package:firebase_chat/ChatView/user_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_chat/Login/login.dart';



class ChatScreen extends StatefulWidget {
String Code;
String Name;
String Photo;
String senderName;
String senderUid;
String senderEmail;
  ChatScreen({Key key,this.Code,this.Name,this.Photo,this.senderName,this.senderUid,this.senderEmail}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin,WidgetsBindingObserver {

  final TextEditingController _messageTextController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool isscroolvisible = false;

  DatabaseReference rootRef = FirebaseDatabase.instance.reference();
  String groupChatId;
  String peerId;
  String peerAvatar;
  String id;
  final secureStorage = new FlutterSecureStorage();
  File imageFile;
  bool isLoading = false;
  String imageUrl;
  int _limit = 20;
  final int _limitIncrement = 20;
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    groupChatId = '';
    listScrollController.addListener(_scrollListener);

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
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
        print('offline');
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.senderUid)
            .update({'onlineStatus': "last seen at ${DateFormat('MMM dd').add_jm().format(DateTime.now())}"});
      } else if (state == AppLifecycleState.resumed){
        print('online');
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.senderUid)
            .update({'onlineStatus': "Online"});
      }
      print("ssssss $state");
    });
  }
  readLocal() async {
    peerId = widget.Code;
    id = await secureStorage.read(key: "id") ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': peerId});

    setState(() {});
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

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
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
      title:
          Hero(
        tag: "AppBar",
        child:
            Material(
              color: Colors.transparent,
              child:
     GestureDetector(
       onTap: () {
         Navigator.push(
             context,
             MaterialPageRoute(
                 builder: (context) => UserDetails(url: "AppBar",image: widget.Photo,uid: widget.Code,))).then((value)   {

                 print("assssss");
                 setState(() {

                 });
         });
       },
       child:  Row(
         children: [
           Container(
               width: 35.0,
               height: 35.0,
               decoration: new BoxDecoration(
                   shape: BoxShape
                       .circle,
                   color: Colors
                       .black12,
                   image: new DecorationImage(
                       fit: BoxFit
                           .cover,
                       image: NetworkImage(
                           widget.Photo)))),

           StreamBuilder(
             stream: FirebaseFirestore.instance.collection("users").where("uid",isEqualTo: widget.Code).snapshots(),
             builder: (context, snap) {
               if (snap.hasData) {

                 return   Container(
                   padding: EdgeInsets.only(left: 15),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Container(
                         child:    Text("${snap.data.documents[0]['name'] != null ? snap.data.documents[0]['name'] : ''}",style: TextStyle(fontSize: 16,color: Colors.white),),
                       ),
                       snap.data.documents[0]['onlineStatus'] != '' ? Container(
                         child:    Text("${snap.data.documents[0]['onlineStatus'] != null ? snap.data.documents[0]['onlineStatus'] : ''}",style: TextStyle(fontSize: 12,color: Colors.white),),
                       ):SizedBox(),

                     ],
                   ),
                 );
               }
               else
                 return Center(
                   child: Container(),
                 );
             },
           ),


         ],
       ),
     ),
     ),
     ),

      backgroundColor: Colors.white10,
    );
  }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        new Flexible(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasData) {

                  return  new ListView.builder(
                    padding: new EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => message(snap.data.documents[index]),
                    itemCount: snap.data.documents.length,
                    controller: listScrollController,
                  );
                }
                else
                  return Center(
                    child: Container(),
                  );
              },
            ),),
        // StreamBuilder(
        //   stream: rootRef.child("typing").onValue,
        //   builder: (context, snap) {
        //     if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {
        //       Map data = snap.data.snapshot.value;
        //       print(data["name"]);
        //       return data["name"] != widget.Name && data["name"] != '' ? Container(
        //         padding: EdgeInsets.only(left: 20),
        //         alignment: Alignment.centerLeft,
        //         child: Text(data["name"].toString() + " is typing..",style: TextStyle(color: Colors.white),),
        //       ) : SizedBox();
        //     }
        //     else
        //       return Center(
        //         child: Container(),
        //       );
        //   },
        // ),
        Padding(padding: EdgeInsets.only(top: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            Container(
              width: MediaQuery.of(context).size.width - 100,
              margin: EdgeInsets.only(bottom: 2),
              child:
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30),
                child:  new TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _messageTextController,
                  minLines: 1,
                  maxLines: 3,
                  onChanged: (text) {
                    // if (text != '') {
                    //   rootRef.child(widget.Code).child("typing").update({
                    //     "name" : widget.Name
                    //   });
                    // } else {
                    //   rootRef.child(widget.Code).child("typing").update({
                    //     "name" : ''
                    //   });
                    // }
                    // print(text);
                  },
                  decoration:
                  new InputDecoration(border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none
                    ),
                  ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(12),
                      suffixIcon:  IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () {
                          filePicker(context,'image');
                        },
                        color: Colors.grey,
                      ),
                      hintText: "Type here...", hintStyle: TextStyle(fontFamily: 'Nunito',color: HexColor.fromHex('#C5C5C5'),fontSize: 13 , fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            GestureDetector(
              onTap:  () async {
                // _publishMessage(_messageTextController.text);
                onSendMessage(_messageTextController.text,0);
              },
              child:
              ClipOval(
                child:
                Container(
                  child:  Material(
                    elevation: 5,
                    child: Ink(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.deepPurple ,Colors.deepOrangeAccent],
                              begin: const FractionalOffset(0.0, 0.0),
                              end: const FractionalOffset(1.3, 1.0),
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp
                          ),
                          borderRadius: BorderRadius.circular(50.0)
                      ),
//                      splashColor: Colors.blue, // inkwell color
                      child: Icon(
                        Icons.send,color: Colors.white,
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



   deleteMessage(data) {
     return showModalBottomSheet<void>(context: context,
         builder: (BuildContext context) {
           return Container(
               child: new Wrap(
                   children: <Widget>[
                     new ListTile(
                         leading: new Icon(Icons.delete),
                         title: new Text('Delete'),
                         onTap: () async {
                           await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                             await myTransaction.delete(data.reference);
                           }).then((value) => Navigator.pop(context));
                         }

                     ),

                   ]
               )
           );
         });
   }



  Widget message (data) {
    return data['idFrom'] == widget.senderUid ? Container(
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
                        ?
                        GestureDetector(
                          onLongPress: () async {
                            deleteMessage(data);
                            // print(data['content']);
                          },
                            child:
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: FlatButton(
                        child:  Hero(
                          tag: 'Photo',
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.deepPurple),
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
                              errorWidget: (context, url, error) => Material(
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
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullPhoto(
                                      url: data['content'])));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                    )) :    GestureDetector(
                      onLongPress: () async {
                        deleteMessage(data);
                        // await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                        //   await myTransaction.delete(data.reference);
                        // });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10.0, left: 90),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.white38],
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(1.2, 1.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp
                            ),
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),topRight:Radius.circular(16),topLeft: Radius.circular(19) )
                        ),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                new Container(
                                  margin: const EdgeInsets.only(top: 12 ,left: 12,right: 35,bottom: 12),
                                  child: new Text(data['content'].toString(),style: TextStyle(fontSize: 18,color: Colors.white),),
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
    ) : Container(
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
                      child: FlatButton(
                        child:  Hero(
                          tag: '${data['content']}',
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.deepPurple),
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
                              errorWidget: (context, url, error) => Material(
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
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullPhoto(
                                      url: data['content'])));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                    ) :  GestureDetector(
                      onTap: () {

                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 90.0, left: 10),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.white38, Colors.black38],
//                    begin: Alignment.topLeft,
//                    end: Alignment.bottomRight,
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(1.2, 1.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp

                            ),
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(16),topRight:Radius.circular(16),topLeft: Radius.circular(19) )
                        ),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                new Container(
                                  margin: const EdgeInsets.only(top: 12 ,left: 12,right: 35,bottom: 12),
                                  child: new Text(data['content'].toString(),style: TextStyle(fontSize: 18,color: Colors.white),),
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
      var newkey = rootRef.child("Messages").push().key;
      String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
      DateTime now = DateTime.now();
      String time = new DateFormat.jm().format(now);
      rootRef.child("Messages").child(newkey).set({
        "Sender" : widget.senderName,
        "SenderCode" : widget.senderUid,
        "Code" : widget.Code,
        "Message" : text.trim(),
        "created" : int.parse(timestamp()),
        "Time" : "$time",
      });
      _messageTextController.clear();
      // rootRef.child(widget.Code).child("typing").update({
      //   "name" : ''
      // });
    }
    }
  Future uploadFile(file,fileType) async {
    String Url;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference;
    if (fileType == 1) {
      reference = FirebaseStorage.instance.ref().child('images/$fileName');
    } else if (fileType == 2) {
      reference = FirebaseStorage.instance.ref().child('audios/$fileName');
    } else if (fileType == 3) {
      reference = FirebaseStorage.instance.ref().child('videos/$fileName');
    } else if (fileType == 4) {
      reference = FirebaseStorage.instance.ref().child('documents/$fileName');
    }
    StorageUploadTask uploadTask = reference.putFile(file);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      Url = downloadUrl;
      print(downloadUrl);
      setState(() {
        isLoading = false;
        onSendMessage(Url, fileType);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
    });
  }
  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(imageFile,1);
    }
  }
  Future filePicker(BuildContext context,fileType) async {
    File file;
    String fileName;
    try {
      if (fileType == 'image') {
        file = await FilePicker.getFile(type: FileType.IMAGE);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        uploadFile(file,1);
      }
      if (fileType == 'audio') {
        file = await FilePicker.getFile(type: FileType.AUDIO);        fileName = p.basename(file.path);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        uploadFile(file,2);
      }
      if (fileType == 'video') {
        file = await FilePicker.getFile(type: FileType.VIDEO);        fileName = p.basename(file.path);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        uploadFile(file,3);
      }
      if (fileType == 'pdf' || fileType == 'others') {
        file = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'pdf');        fileName = p.basename(file.path);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        uploadFile(file,4);
      }
    } on PlatformException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
      );
    }
  }
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = audio, 3 = video, 4 = others and pdf
    if (content.trim() != '') {
      _messageTextController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'Sender': widget.senderName,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {

    }
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