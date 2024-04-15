import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/ChatView/full_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserDetails extends StatelessWidget {
  final String url;
  final String image;
  final String uid;

  UserDetails({Key key, @required this.url,this.image,this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       bottom: Radius.circular(30),
      //     ),
      //   ),
      //   // title: Text(
      //   //   'FULL PHOTO',
      //   //   style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
      //   // ),
      //   centerTitle: true,
      //   backgroundColor: Colors.white10,
      // ),
      backgroundColor: Colors.black,
      body: UserDetailsScreen(url: url,image: image,uid: this.uid,),
    );
  }
}

class UserDetailsScreen extends StatefulWidget {
  final String url;
  final String image;
  final String uid;

  UserDetailsScreen({Key key, @required this.url,this.image,this.uid}) : super(key: key);

  @override
  State createState() => UserDetailsScreenState(url: url,image: image,uid: uid);
}

class UserDetailsScreenState extends State<UserDetailsScreen> {
  final String url;
  final String image;
  final String uid;

  UserDetailsScreenState({Key key, @required this.url,this.image,this.uid});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").where("uid",isEqualTo: uid).snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            print(snap.data.documents[0]['email']);
            return  Hero(
                tag: 'AppBars',
                child: Scaffold(
                  body: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight: 300.0,
                          backgroundColor: Colors.white10,
                          floating: false,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            titlePadding: EdgeInsets.only(left: 48,bottom: 18),
                            centerTitle: false,
                            // collapseMode: CollapseMode.pin,
                            title: Container(
                              child: Text("${snap.data.documents[0]['name']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,

                                  )),
                            ),
                            background: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: snap.data.documents[0]['photoUrl'])));
                              },
                              child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                  child: Icon(Icons.account_circle,size: 200,)
                              ),
                              // errorWidget: (context, url, error) => Material(
                              //   child: Image.asset(
                              //     'images/img_not_available.jpeg',
                              //     width: 200.0,
                              //     height: 200.0,
                              //     fit: BoxFit.cover,
                              //   ),
                              //   borderRadius: BorderRadius.all(
                              //     Radius.circular(8.0),
                              //   ),
                              //   clipBehavior: Clip.hardEdge,
                              // ),
                              imageUrl: snap.data.documents[0]['photoUrl'],
                              fit: BoxFit.cover,
                              color: Colors.black12,
                              colorBlendMode: BlendMode.darken,
                            ),),),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 75),
                        )
                      ];
                    },
                    body: Container(
                      padding: EdgeInsets.only(top: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Text("About",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),),
                          ),
                          Container(
                            child: Card(
                              color: Colors.white10,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.all(15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Container(
                                      child: Text("Status",style: TextStyle(color: Colors.white,fontSize: 12),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text("${snap.data.documents[0]['Status'] != null ? snap.data.documents[0]['Status']: '' }",style: TextStyle(color: Colors.white,fontSize: 18),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text("Phone Number",style: TextStyle(color: Colors.white,fontSize: 12),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text("${snap.data.documents[0]['PhoneNumber'] != null ? snap.data.documents[0]['PhoneNumber']: '' }",style: TextStyle(color: Colors.white,fontSize: 18),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text("Email",style: TextStyle(color: Colors.white,fontSize: 12),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text("${snap.data.documents[0]['email'] != null ? snap.data.documents[0]['email']: '' }",style: TextStyle(color: Colors.white,fontSize: 18),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text("About ${snap.data.documents[0]['name']}",style: TextStyle(color: Colors.white,fontSize: 12),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text("${snap.data.documents[0]['AboutMe'] != null ? snap.data.documents[0]['AboutMe']: '' }",style: TextStyle(color: Colors.white,fontSize: 18),),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: Colors.black,
                )
            );
          }
          else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      );
  }
}
