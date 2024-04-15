import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService  {
    final secureStorage = new FlutterSecureStorage();
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive',
    ],
  );
  DatabaseReference rootRef = FirebaseDatabase.instance.reference();


  Future<bool> islogedin() async {
    var res = await secureStorage.read(key: "user");
    if (res.toString() != 'null') {
      return true;
    } else {
      return false;
    }
  }
  Future <User> googleSignin(BuildContext context) async {
    User currentUser;
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken, );
      final User user = await FirebaseAuth.instance.signInWithCredential(credential).then((value) => value.user);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      currentUser =  FirebaseAuth.instance.currentUser;
      await secureStorage.write(key: "user", value: currentUser.toString());
      await secureStorage.write(key: "uid", value: currentUser.uid.toString());
      await secureStorage.write(key: "name", value: currentUser.displayName.toString());
      await secureStorage.write(key: "email", value: currentUser.email.toString());

      assert(user.uid == currentUser.uid);
      print(currentUser);
      final QuerySnapshot result =
      await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: currentUser.uid).get();
      final List < DocumentSnapshot > documents = result.docs;

      if (documents.length == 0) {
        // Update data to server if new user
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set(
            { 'name': currentUser.displayName, 'photoUrl': currentUser.photoURL, 'uid': currentUser.uid,'email' :currentUser.email,'PhoneNumber' : currentUser.phoneNumber,'Status' : 'Hey There!','AboutMe' : 'Developer','onlineStatus' : 'Online' });
        await secureStorage.write(key: "id", value: currentUser.uid.toString());
        await secureStorage.write(key: "name", value: currentUser.displayName.toString());
        await secureStorage.write(key: "photoUrl", value: currentUser.photoURL.toString());
        await secureStorage.write(key: "email", value: currentUser.email.toString());
      } else {
        print("User Name : ${documents.length}");
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update(
            { 'name': documents[0].data()['name'], 'photoUrl': documents[0].data()['photoUrl'], 'uid': currentUser.uid,'email' :currentUser.email,'PhoneNumber' : documents[0].data()['PhoneNumber'],'Status' : documents[0].data()['Status'],'AboutMe' : documents[0].data()['AboutMe'], });
        await secureStorage.write(key: "id", value: documents[0].data()['uid']);
        await secureStorage.write(key: "name", value: documents[0].data()['name']);
        await secureStorage.write(key: "photoUrl", value: documents[0].data()['photoUrl']);
        await secureStorage.write(key: "email", value: documents[0].data()['email']);
      }
      // var newkey = rootRef.child("Users").push().key;
      // rootRef.child("Users").orderByChild("uid").equalTo("${currentUser.uid}").once().then((DataSnapshot snapshot) {
      //   if (snapshot.value == null) {
      //     rootRef.child("Users").child(newkey).set({
      //       "name" : "${currentUser.displayName}",
      //       "email" : "${currentUser.email}",
      //       "PhoneNumber" : "${currentUser.phoneNumber}",
      //       "Photo" : "${currentUser.photoURL}",
      //       "uid" : "${currentUser.uid}",
      //     });
      //   }
      // });


      return user;
    } catch (e) {
      print(e);
      return currentUser;
    }
  }
  Future <bool> googleSignout() async {
    // await auth.signOut();
    await _googleSignIn.signOut().then((value) {
      print(value.displayName);
    });
    return true;
  }
}
