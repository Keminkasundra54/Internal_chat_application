import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullPhoto extends StatelessWidget {
  final String url;
  final bool showEdit;
  late File imageFile;
  String uid;
  // FullPhoto({Key? key, required this.url,required this.showEdit,required this.uid}) : super(key: key);

  FullPhoto({Key? key, required this.url, required this.showEdit, required this.uid})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        actions: [
          showEdit != null ? IconButton(icon: Icon(Icons.edit), onPressed: () {
            showEditoptions(context);
          }):SizedBox(),
        ],
        // title: Text(
        //   'FULL PHOTO',
        //   style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        // ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FullPhotoScreen(url: url),
    );
  }
  showEditoptions(context) {
    return showModalBottomSheet<void>(context: context,
        builder: (BuildContext context) {
          return Container(
              child: new Wrap(
                  children: <Widget>[

                    new ListTile(
                        leading: new Icon(Icons.camera_enhance),
                        title: new Text('Camera'),
                        onTap: () async {
                          getImage(true,context);
                        }

                    ),
                    new ListTile(
                        leading: new Icon(Icons.photo_album),
                        title: new Text('Galary'),
                        onTap: () async {
                          getImage(false,context);
                        }

                    ),
                  ]
              )
          );
        });
  }

  // Future getImage(bool camera ,context) async {
  //   ImagePicker imagePicker = ImagePicker();
  //   PickedFile pickedFile;
  //   if (camera) {
  //     pickedFile = await imagePicker.getImage(source: ImageSource.camera);

  //   } else {
  //     pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

  //   }
  //   imageFile = File(pickedFile.path);

  //   uploadFile(imageFile,1);
  //   Navigator.pop(context);
  //   }

Future getImage(bool camera, context) async {
  final ImagePicker _picker = ImagePicker();
  PickedFile? pickedFile;

  try {
    if (camera) {
      pickedFile = await _picker.pickImage(source: ImageSource.camera) as PickedFile?;
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery) as PickedFile?;
    }

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      uploadFile(imageFile, 1);
      Navigator.pop(context);
    }
  } catch (e) {
    print(e); // Handle errors during image picking
  }
}


   
  Future uploadFile(file,fileType) async {
    // String Url;
    // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    // StorageReference reference;
    // reference = FirebaseStorage.instance.ref().child('profilePics/$fileName');
    // StorageUploadTask uploadTask = reference.putFile(file);
    // StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    // storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
    //   Url = downloadUrl;
    //   print(downloadUrl);
    //   FirebaseFirestore.instance.collection('users').doc(uid).update(
    //       { 'photoUrl': downloadUrl});

    // }, onError: (err) {

    // });
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key? key, required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key? key, required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onLongPress:   () {
          Navigator.pop(context);
        },
        child:
      Container(
        child:
        Hero(
          tag: 'Photo',
          child: PhotoView(imageProvider: CachedNetworkImageProvider(url))
        ),
        ),

        );
  }
}
