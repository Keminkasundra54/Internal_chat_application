import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';


class Profile extends StatefulWidget {
  final String? url;
  final String? image;
  final String? uid;

  Profile({Key? key, required this.url, required this.image, required this.uid})
      : super(key: key);

  @override
  State createState() => ProfileState(url: url!, image: image!, uid: uid!);
}

final String emptyFilePath = '';
final File emptyFile = File(emptyFilePath);

class ProfileState extends State<Profile> {
  final secureStorage = new FlutterSecureStorage();
  final String url;
  final String image;
  final String uid;
  bool loader = false;
  ProfileState({
    Key? key,
    required this.url,
    required this.image,
    required this.uid,
  }); // Initialize imageFile with an empty file
       // Initialize imageUrl with an empty string
  late File imageFile;
  bool isLoading = false;
  late String imageUrl;
  bool showStatus = false;
  bool showName = false;
  bool showNumber = false;
  bool showAbout = false;

  final TextEditingController _controller = new TextEditingController();
  final TextEditingController _controllerName = new TextEditingController();
  final TextEditingController _controllerNumber = new TextEditingController();
  final TextEditingController _controllerAbout = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  // Widget build(BuildContext context) {
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance
  //         .collection("users")
  //         .where("uid", isEqualTo: uid)
  //         .snapshots(),
  //     builder: (context, snap) {
  //       if (snap.hasData && snap.data != null) {
  //         var data = snap.data as QuerySnapshot<Map<String, dynamic>>;
  //         if (data.docs.isNotEmpty) {
  //           var document = data.docs[0];
  //           _controllerAbout.text =
  //               document['AboutMe'] != null ? document['AboutMe'] : '';
  //           _controllerName.text =
  //               document['name'] != null ? document['name'] : '';
  //           _controllerNumber.text =
  //               document['PhoneNumber'] != null ? document['PhoneNumber'] : '';
  //           _controller.text =
  //               document['Status'] != null ? document['Status'] : '';

  //           return Scaffold(
  //             appBar: AppBar(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.vertical(
  //                   bottom: Radius.circular(30),
  //                 ),
  //               ),
  //               title: Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text("Profile"),
  //                 ],
  //               ),
  //               actions: [
  //                 IconButton(
  //                     icon: Icon(Icons.logout),
  //                     onPressed: () async {
  //                       await secureStorage.deleteAll();
  //                       Navigator.pushAndRemoveUntil(
  //                           context,
  //                           MaterialPageRoute(builder: (context) => Login()),
  //                           (route) => false);
  //                     }),
  //                 Padding(
  //                   padding: EdgeInsets.only(right: 20),
  //                 )
  //               ],
  //               backgroundColor: Colors.white10,
  //             ),
  //             body: SingleChildScrollView(
  //               child: Container(
  //                 padding: EdgeInsets.only(top: 0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   // mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(
  //                       margin: EdgeInsets.all(35),
  //                       child: Stack(
  //                         children: <Widget>[
  //                           GestureDetector(
  //                             onTap: () {
  //                               // Navigator.push(
  //                               //     context,
  //                               //     MaterialPageRoute(
  //                               //         builder: (context) => FullPhoto(
  //                               //               url: snap.data.documents[0]
  //                               //                   ['photoUrl'],
  //                               //               uid: uid,
  //                               //             )));
  //                             },
  //                             child: Hero(
  //                                 tag: 'Photo',
  //                                 child: new Container(
  //                                     width: 150.0,
  //                                     height: 150.0,
  //                                     decoration: new BoxDecoration(
  //                                         shape: BoxShape.circle,
  //                                         image: new DecorationImage(
  //                                             fit: BoxFit.cover,
  //                                             image: NetworkImage(
  //                                                 snap.data.documents[0]
  //                                                     ['photoUrl']))))),
  //                           ),
  //                           Positioned(
  //                             right: 0,
  //                             bottom: 10,
  //                             child: isLoading
  //                                 ? Container(
  //                                     margin:
  //                                         EdgeInsets.only(right: 10, bottom: 6),
  //                                     height: 20,
  //                                     width: 20,
  //                                     child: CircularProgressIndicator(
  //                                       valueColor:
  //                                           AlwaysStoppedAnimation<Color>(
  //                                               Colors.white),
  //                                       backgroundColor: Colors.deepPurple,
  //                                     ),
  //                                   )
  //                                 : GestureDetector(
  //                                     child: Container(
  //                                       child: Icon(
  //                                         Icons.camera_alt,
  //                                         color: Colors.teal,
  //                                         size: 35,
  //                                       ),
  //                                     ),
  //                                     onTap: () {
  //                                       showEditoptions();
  //                                     },
  //                                   ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                     Container(
  //                       child: Card(
  //                         color: Colors.white10,
  //                         child: Container(
  //                           width: MediaQuery.of(context).size.width,
  //                           margin: EdgeInsets.all(15),
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Row(
  //                                 children: [
  //                                   Container(
  //                                     width: MediaQuery.of(context).size.width -
  //                                         100,
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.start,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Container(
  //                                           child: Text(
  //                                             "Name",
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 12),
  //                                           ),
  //                                         ),
  //                                         Container(
  //                                           child: TextFormField(
  //                                             controller: _controllerName,
  //                                             enabled: showName,
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 18),
  //                                             decoration: InputDecoration(
  //                                               isDense: true,
  //                                               border: InputBorder.none,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     width: 50,
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.end,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.end,
  //                                       children: [
  //                                         IconButton(
  //                                           icon: Icon(
  //                                             showName
  //                                                 ? Icons.check
  //                                                 : Icons.edit,
  //                                             color: Colors.white,
  //                                             size: 20,
  //                                           ),
  //                                           onPressed: () {
  //                                             if (showName) {
  //                                               FirebaseFirestore.instance
  //                                                   .collection('users')
  //                                                   .doc(uid)
  //                                                   .update({
  //                                                 'name': _controllerName.text
  //                                               }).then((value) => () {});
  //                                             } else {
  //                                               _controllerName.text =
  //                                                   snap.data.documents[0]
  //                                                               ['name'] !=
  //                                                           null
  //                                                       ? snap.data.documents[0]
  //                                                           ['name']
  //                                                       : '';
  //                                             }
  //                                             setState(() {
  //                                               showName = !showName;
  //                                             });
  //                                           },
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 children: [
  //                                   Container(
  //                                     width: MediaQuery.of(context).size.width -
  //                                         100,
  //                                     margin: EdgeInsets.only(top: 10),
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.start,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Container(
  //                                           child: Text(
  //                                             "Status",
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 12),
  //                                           ),
  //                                         ),
  //                                         Container(
  //                                           child: TextFormField(
  //                                             controller: _controller,
  //                                             enabled: showStatus,
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 18),
  //                                             decoration: InputDecoration(
  //                                               isDense: true,
  //                                               border: InputBorder.none,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     width: 50,
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.end,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.end,
  //                                       children: [
  //                                         IconButton(
  //                                           icon: Icon(
  //                                             showStatus
  //                                                 ? Icons.check
  //                                                 : Icons.edit,
  //                                             color: Colors.white,
  //                                             size: 20,
  //                                           ),
  //                                           onPressed: () {
  //                                             if (showStatus) {
  //                                               FirebaseFirestore.instance
  //                                                   .collection('users')
  //                                                   .doc(uid)
  //                                                   .update({
  //                                                 'Status': _controller.text
  //                                               }).then((value) => () {});
  //                                             } else {
  //                                               _controller.text =
  //                                                   snap.data.documents[0]
  //                                                               ['Status'] !=
  //                                                           null
  //                                                       ? snap.data.documents[0]
  //                                                           ['Status']
  //                                                       : '';
  //                                             }
  //                                             setState(() {
  //                                               showStatus = !showStatus;
  //                                             });
  //                                           },
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 children: [
  //                                   Container(
  //                                     width: MediaQuery.of(context).size.width -
  //                                         100,
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.start,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Container(
  //                                           padding: EdgeInsets.only(top: 20),
  //                                           child: Text(
  //                                             "Phone Number",
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 12),
  //                                           ),
  //                                         ),
  //                                         Container(
  //                                           child: TextFormField(
  //                                             controller: _controllerNumber,
  //                                             enabled: showNumber,
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 18),
  //                                             keyboardType:
  //                                                 TextInputType.number,
  //                                             decoration: InputDecoration(
  //                                               isDense: true,
  //                                               border: InputBorder.none,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     width: 50,
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.end,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.end,
  //                                       children: [
  //                                         IconButton(
  //                                           icon: Icon(
  //                                             showNumber
  //                                                 ? Icons.check
  //                                                 : Icons.edit,
  //                                             color: Colors.white,
  //                                             size: 20,
  //                                           ),
  //                                           onPressed: () {
  //                                             if (showNumber) {
  //                                               FirebaseFirestore.instance
  //                                                   .collection('users')
  //                                                   .doc(uid)
  //                                                   .update({
  //                                                 'PhoneNumber':
  //                                                     _controllerNumber.text
  //                                               }).then((value) => () {});
  //                                             } else {
  //                                               _controllerNumber.text = snap
  //                                                               .data
  //                                                               .documents[0]
  //                                                           ['PhoneNumber'] !=
  //                                                       null
  //                                                   ? snap.data.documents[0]
  //                                                       ['PhoneNumber']
  //                                                   : '';
  //                                             }
  //                                             setState(() {
  //                                               showNumber = !showNumber;
  //                                             });
  //                                           },
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 children: [
  //                                   Container(
  //                                     width: MediaQuery.of(context).size.width -
  //                                         100,
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.start,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Container(
  //                                           padding: EdgeInsets.only(top: 20),
  //                                           child: Text(
  //                                             "About",
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 12),
  //                                           ),
  //                                         ),
  //                                         Container(
  //                                           child: TextFormField(
  //                                             controller: _controllerAbout,
  //                                             enabled: showAbout,
  //                                             style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: 18),
  //                                             decoration: InputDecoration(
  //                                               isDense: true,
  //                                               border: InputBorder.none,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   Container(
  //                                     width: 50,
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.end,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.end,
  //                                       children: [
  //                                         IconButton(
  //                                           icon: Icon(
  //                                             showAbout
  //                                                 ? Icons.check
  //                                                 : Icons.edit,
  //                                             color: Colors.white,
  //                                             size: 20,
  //                                           ),
  //                                           onPressed: () {
  //                                             if (showAbout) {
  //                                               FirebaseFirestore.instance
  //                                                   .collection('users')
  //                                                   .doc(uid)
  //                                                   .update({
  //                                                 'AboutMe':
  //                                                     _controllerAbout.text
  //                                               }).then((value) => () {});
  //                                             } else {
  //                                               _controllerAbout.text =
  //                                                   snap.data.documents[0]
  //                                                               ['AboutMe'] !=
  //                                                           null
  //                                                       ? snap.data.documents[0]
  //                                                           ['AboutMe']
  //                                                       : '';
  //                                             }
  //                                             setState(() {
  //                                               showAbout = !showAbout;
  //                                             });
  //                                           },
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Container(
  //                                 padding: EdgeInsets.only(top: 20),
  //                                 child: Text(
  //                                   "Email",
  //                                   style: TextStyle(
  //                                       color: Colors.white, fontSize: 12),
  //                                 ),
  //                               ),
  //                               Container(
  //                                 padding: EdgeInsets.only(top: 5),
  //                                 child: Text(
  //                                   "${snap.data.documents[0]['email'] != null ? snap.data.documents[0]['email'] : ''}",
  //                                   style: TextStyle(
  //                                       color: Colors.white, fontSize: 18),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             backgroundColor: Colors.black,
  //           );
  //         }
  //       } else
  //         return Center(
  //           child: CircularProgressIndicator(),
  //         );
  //     },
  //   );
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Send a message to the server
            // socket.emit('chat_message', 'Hello from Flutter!');
          },
          child: Text('Send Message'),
        ),
      ),
    );
  }
  // Future getImage(bool camera) async {
  //   ImagePicker imagePicker = ImagePicker();
  //   PickedFile pickedFile;
  //   if (camera) {
  //     pickedFile = await imagePicker.getImage(source: ImageSource.camera);
  //   } else {
  //     pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
  //   }
  //   imageFile = File(pickedFile.path);

  //   if (imageFile != null) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     uploadFile(imageFile, 1);
  //     Navigator.pop(context);
  //   }
  // }

  Future getImage(bool camera) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;
    if (camera) {
      // XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
      XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
    }

    // Handle the scenario where no image is picked (optional)
    print('No image selected.');
      setState(() {
      isLoading = true;
    });
    uploadFile(imageFile, 1);
    Navigator.pop(context);
    }

  Future uploadFile(File file, int fileType) async {
    // String Url;
    // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    // StorageReference reference;
    // reference = FirebaseStorage.instance.ref().child('profilePics/$fileName');
    // StorageUploadTask uploadTask = reference.putFile(file);
    // StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    // storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
    //   Url = downloadUrl;
    //   print(downloadUrl);
    //   FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(uid)
    //       .update({'photoUrl': downloadUrl});
    //   setState(() {
    //     isLoading = false;
    //   });
    // }, onError: (err) {
    //   setState(() {
    //     isLoading = false;
    //   });
    // });
  }

  showEditoptions() {
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: new Wrap(children: <Widget>[
            new ListTile(
                leading: new Icon(Icons.camera_enhance),
                title: new Text('Camera'),
                onTap: () async {
                  getImage(true);
                }),
            new ListTile(
                leading: new Icon(Icons.photo_album),
                title: new Text('Galary'),
                onTap: () async {
                  getImage(false);
                }),
          ]));
        });
  }

  showEditoptions2(type) {
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "Enter your name",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                  Container(
                    child: TextFormField(
                      controller: _controller,
                    ),
                  ),
                ],
              ));
        });
  }
}
