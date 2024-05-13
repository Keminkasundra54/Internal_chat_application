// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

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

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "photoUrl": photoUrl,
        "id": id,
        "googleId": googleId,
      };
}

late IO.Socket socket;
final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

const String clientId =
    '37266721800-s6km4jf18vmnnf4t76bieg5pejud2odr.apps.googleusercontent.com';

class AuthService {
  final secureStorage = new FlutterSecureStorage();

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'openid',
    'profile',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/userinfo.profile',
  ], clientId: clientId);
  // DatabaseReference rootRef = FirebaseDatabase.instance.reference();

  Future<bool> islogedin() async {
    var res = await secureStorage.read(key: "user");
    if (res.toString() != 'null') {
      return true;
    } else {
      return false;
    }
  }

  // Future<User?> googleSignin(BuildContext context) async {
  //   User? currentUser;
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser!.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     // final User user = await FirebaseAuth.instance
  //     //     .signInWithCredential(credential)
  //     //     .then((value) => value.user!);
  //     assert(user.email != null);
  //     assert(user.displayName != null);
  //     assert(!user.isAnonymous);
  //     assert(await user.getIdToken() != null);
  //     // currentUser = FirebaseAuth.instance.currentUser!;
  //     await secureStorage.write(key: "user", value: currentUser.toString());
  //     await secureStorage.write(key: "uid", value: currentUser.uid.toString());
  //     await secureStorage.write(
  //         key: "name", value: currentUser.displayName.toString());
  //     await secureStorage.write(
  //         key: "email", value: currentUser.email.toString());

  //     assert(user.uid == currentUser.uid);
  //     print(currentUser);
  //     final QuerySnapshot result = await FirebaseFirestore.instance
  //         .collection('users')
  //         .where('uid', isEqualTo: currentUser.uid)
  //         .get();
  //     final List<DocumentSnapshot> documents = result.docs;

  //     // if (documents.length == 0) {
  //     //   // Update data to server if new user
  //     //   FirebaseFirestore.instance
  //     //       .collection('users')
  //     //       .doc(currentUser.uid)
  //     //       .set({
  //     //     'name': currentUser.displayName,
  //     //     'photoUrl': currentUser.photoURL,
  //     //     'uid': currentUser.uid,
  //     //     'email': currentUser.email,
  //     //     'PhoneNumber': currentUser.phoneNumber,
  //     //     'Status': 'Hey There!',
  //     //     'AboutMe': 'Developer',
  //     //     'onlineStatus': 'Online'
  //     //   });
  //     //   await secureStorage.write(key: "id", value: currentUser.uid.toString());
  //     //   await secureStorage.write(
  //     //       key: "name", value: currentUser.displayName.toString());
  //     //   await secureStorage.write(
  //     //       key: "photoUrl", value: currentUser.photoURL.toString());
  //     //   await secureStorage.write(
  //     //       key: "email", value: currentUser.email.toString());
  //     // } else {
  //     //   print("User Name : ${documents.length}");
  //     //   FirebaseFirestore.instance
  //     //       .collection('users')
  //     //       .doc(currentUser.uid)
  //     //       .update({
  //     //     'name': documents[0].data()['name'],
  //     //     'photoUrl': documents[0].data()['photoUrl'],
  //     //     'uid': currentUser.uid,
  //     //     'email': currentUser.email,
  //     //     'PhoneNumber': documents[0].data()['PhoneNumber'],
  //     //     'Status': documents[0].data()['Status'],
  //     //     'AboutMe': documents[0].data()['AboutMe'],
  //     //   });
  //     //   await secureStorage.write(key: "id", value: documents[0].data()['uid']);
  //     //   await secureStorage.write(
  //     //       key: "name", value: documents[0].data()['name']);
  //     //   await secureStorage.write(
  //     //       key: "photoUrl", value: documents[0].data()['photoUrl']);
  //     //   await secureStorage.write(
  //     //       key: "email", value: documents[0].data()['email']);
  //     // }

  //     if (documents.isNotEmpty) {
  //       if (documents.length == 0) {
  //         // Update data to server if new user
  //         FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(currentUser.uid)
  //             .set({
  //           'name': currentUser.displayName,
  //           'photoUrl': currentUser.photoURL,
  //           'uid': currentUser.uid,
  //           'email': currentUser.email,
  //           'PhoneNumber': currentUser.phoneNumber,
  //           'Status': 'Hey There!',
  //           'AboutMe': 'Developer',
  //           'onlineStatus': 'Online'
  //         });
  //         await secureStorage.write(
  //             key: "id", value: currentUser.uid.toString());
  //         await secureStorage.write(
  //             key: "name", value: currentUser.displayName.toString());
  //         await secureStorage.write(
  //             key: "photoUrl", value: currentUser.photoURL.toString());
  //         await secureStorage.write(
  //             key: "email", value: currentUser.email.toString());
  //       } else {
  //         print("User Name : ${documents.length}");
  //         Map<String, dynamic>? userData =
  //             documents[0].data() as Map<String, dynamic>?;
  //         if (userData != null) {
  //           FirebaseFirestore.instance
  //               .collection('users')
  //               .doc(currentUser.uid)
  //               .update({
  //             'name':
  //                 userData['name'], // Using null check before accessing fields
  //             'photoUrl': userData['photoUrl'],
  //             'uid': currentUser.uid,
  //             'email': currentUser.email,
  //             'PhoneNumber': userData['PhoneNumber'],
  //             'Status': userData['Status'],
  //             'AboutMe': userData['AboutMe'],
  //           });
  //           await secureStorage.write(key: "id", value: userData['uid']);
  //           await secureStorage.write(key: "name", value: userData['name']);
  //           await secureStorage.write(
  //               key: "photoUrl", value: userData['photoUrl']);
  //           await secureStorage.write(key: "email", value: userData['email']);
  //         }
  //       }
  //     } else {
  //       print('Documents list is empty.');
  //     }

  //     // var newkey = rootRef.child("Users").push().key;
  //     // rootRef.child("Users").orderByChild("uid").equalTo("${currentUser.uid}").once().then((DataSnapshot snapshot) {
  //     //   if (snapshot.value == null) {
  //     //     rootRef.child("Users").child(newkey).set({
  //     //       "name" : "${currentUser.displayName}",
  //     //       "email" : "${currentUser.email}",
  //     //       "PhoneNumber" : "${currentUser.phoneNumber}",
  //     //       "Photo" : "${currentUser.photoURL}",
  //     //       "uid" : "${currentUser.uid}",
  //     //     });
  //     //   }
  //     // });

  //     return user;
  //   } catch (e) {
  //     print(e);
  //     return currentUser;
  //   }
  // }

//   Future<User?> googleSignin(BuildContext context) async {
//     User? currentUser;

//     try {
//       final GoogleSignIn _googleSignIn = GoogleSignIn();
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser!.authentication;
//       print(googleAuth);

//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       print("credential : $credential");
//       print("googleAuth.accessToken : ${googleAuth.accessToken}");
//       print("googleAuth.idToken : ${googleAuth.idToken}");
//       print(googleUser);
//       print(googleUser?.displayName);
//       print(googleUser.runtimeType);
//       print('ok');

//       if (googleUser == null) {
//         return currentUser; // Handle sign-in cancellation
//       }

//       // Process user data
//       // currentUser = User(
//       //   name: googleUser?.displayName ?? "",
//       //   email: googleUser?.email ?? "",
//       //   // Other user attributes
//       // );

//       // Store user data locally or perform any necessary actions
//       _googleSignIn.signInSilently();

//       try {
//         // Replace with your actual Socket.io server URL
//         // socket = IO.io('http://localhost:3000' , <String, dynamic>{
//         socket = IO.io('http://192.168.1.13:8080', <String, dynamic>{
//           'transports': ['websocket'], // Specify transport (optional)
//         });
//         socket.connect();
//         print('Connected to Socket.io server!');
//         socket.emit('chat_message', '$googleUser');
// //         socket.on(
// //             'messageSuccess', (data) => {print(data), currentUser = data,
// //             Map<String, dynamic> userData = data as Map<String, dynamic>;
// // String displayName = userData['displayName'];
// // String email = userData['email'];});

//         // socket.on('messageSuccess', (data) {
//         //   print('data$data');

//         //   // Extract user data from the received map
//         //   Map<String, dynamic> userData = data as Map<String, dynamic>;
//         //   String displayName = userData['displayName'];
//         //   String email = userData['email'];
//         //   String photoUrl = userData['photoUrl'];
//         //   String id = userData['id'];

//         //   currentUser =
//         //       User(name: displayName, email: email, photoUrl: photoUrl, id: id);
//         //   print(currentUser);

//         // });
//         socket.on('connect', (_) => print('Connected'));

//         socket.on('messageSuccess', (data) {
//           print('Received data: $data');

//           // Check if the data is of type Map<String, dynamic>
//           // if (data is Map<String, dynamic>) {
//           //   // Extract user data from the received map
//           //   String displayName = data['displayName'];
//           //   String email = data['email'];
//           //   String photoUrl = data['photoUrl'];
//           //   String id = data['id'];

//           //   // Update currentUser with the received data
//           //   // currentUser = User(
//           //   //   name: displayName,
//           //   //   email: email,
//           //   //   photoUrl: photoUrl,
//           //   //   id: id,
//           //   // );
//           //   if (currentUser == null) {
//           //     currentUser = User(
//           //       name: displayName,
//           //       email: email,
//           //       photoUrl: photoUrl,
//           //       id: id,
//           //     );
//           //   } else {
//           //     // Update currentUser with the received data
//           //     currentUser!.name = displayName;
//           //     currentUser!.email = email;
//           //     currentUser!.photoUrl = photoUrl;
//           //     currentUser!.id = id;
//           //   }
//           //   print('Updated currentUser: $currentUser');
//           // } else {
//           //   print('Received data is not in the expected format.');
//           // }

//           if (data is Map<String, dynamic>) {
//             // Extract user data from the received map
//             String? displayName = data['displayName'];
//             String? email = data['email'];
//             String? photoUrl = data['photoUrl'];
//             String? id = data['id'];

//             // Ensure all required data is present
//             if (displayName != null &&
//                 email != null &&
//                 photoUrl != null &&
//                 id != null) {
//               // Update currentUser with the received data
//               currentUser = User(
//                 name: displayName,
//                 email: email,
//                 photoUrl: photoUrl,
//                 id: id,
//               );

//               print('Updated currentUser: $currentUser');
//             } else {
//               print('Received data is missing required fields.');
//             }
//           } else {
//             print('Received data is not in the expected format.');
//           }
//         });
//         // Handle connection events
//         socket.on('disconnect', (_) => print('Disconnected'));

//         return currentUser;
//         // Return currentUser if it's not null
//         // socket.on('chat_message')
//         // socket.emit('chat_message', {'message': 'Hello, World!'});
// // socket.emit(event)
//         // Handle connection events (optional)
//       } catch (e) {
//         print('Error connecting to Socket.io server: $e');
//         return currentUser;
//       }
//     } catch (e) {
//       print(e);
//       print("Error during Google sign-in: $e");

//       return currentUser;
//     }
//   }

  // Future<User?> googleSignin(BuildContext context) async {
  //   try {
  //     // Initialize Google Sign-In
  //     final GoogleSignIn _googleSignIn = GoogleSignIn();

  //     // Start Google Sign-In process
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  //     if (googleUser == null) {
  //       // Handle sign-in cancellation
  //       print('Sign-in cancelled.');
  //       return null;
  //     }

  //     // Get authentication data
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     // Get user details

  //     // Perform additional actions if needed

  //     // socket = IO.io('http://192.168.1.13:8080', <String, dynamic>{
  //     //   'transports': ['websocket'],
  //     //   "autoConnect": false,
  //     // });
  //     // socket.connect();
  //     // socket.onConnect((_){

  //     // print('Connected');

  //     // print('Connected to Socket.io server!');
  //     // print(googleUser);
  //     //   socket.emit('chat_message', 'testInr');
  //     // if (socket.connected) {
  //     //   socket.emit('chat_message', googleUser);

  //     // } else {
  //     //   print('WebSocket connection is not established.');
  //     // }
  //     // } );
  //     // // final userJson = jsonEncode(currentUser.toJson());

  //     // // socket.emit('chat_message', googleUser.toString());
  //     // socket.on('disconnect', (_) => print('Disconnected'));

  //      socket = IO.io('http://192.168.1.13:3000', <String, dynamic>{
  //       'transports': ['websocket'], // Specify transport (optional)
  //     });
  //     socket.connect();
  //     print('Connected to Socket.io server!');
  //      final googleUserData = {
  //     'displayName': googleUser.displayName,
  //     'email': googleUser.email,
  //     'id': googleUser.id,
  //     'photoUrl': googleUser.photoUrl,
  //   };

  //     socket.on('connect', (_) => print('Connected'));
  // socket.emit('chat_message', googleUserData);

  //     socket.on('disconnect', (_) => print('Disconnected'));
  //             // final User currentUser = await getUserDetails(googleUser, googleAuth);
  //               socket.on('messageSuccess', (data) async {print(data), final currentUser = User(
  //       name: data['displayName'],
  //       email: data['email'],
  //       id: data['id'],
  //       photoUrl: data['photoUrl'],
  //     );}

  //     await saveUserDataLocally(currentUser);
  //     );
  //     _googleSignIn.signInSilently();

  //     return currentUser;
  //   } catch (e) {
  //     // Handle sign-in errors
  //     print('Error during Google sign-in: $e');
  //     return null;
  //   }
  // }

  Future<User?> googleSignin(BuildContext context) async {
    try {
      bool loggedIn = await islogedin();
      if (loggedIn) {
        print('User is already logged in.');
        // You can navigate to the ChatUserList page or any other appropriate page here
        return null; // Returning null as no new sign-in is required
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Sign-in cancelled.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      socket = IO.io('http://192.168.1.13:3000', <String, dynamic>{
        'transports': ['websocket'],
      });
      socket.connect();
      print('Connected to Socket.io server!');
      final googleUserData = {
        'displayName': googleUser.displayName,
        'email': googleUser.email,
        'id': googleUser.id,
        'photoUrl': googleUser.photoUrl,
      };

      socket.on('connect', (_) => print('Connected'));
      socket.emit('chat_message', googleUserData);

      // Use Completer to wait for currentUser to be set
      Completer<User?> completer = Completer<User?>();

      socket.on('messageSuccess', (data) async {
        print(data);
        final currentUser = User(
          name: data['Name'],
          email: data['email'],
          id: data['_id'],
          googleId: data['googleId'],
          photoUrl: data['photoUrl'],
        );
        await saveUserDataLocally(currentUser);
        completer.complete(
            currentUser); // Complete the future when currentUser is set
      });

      socket.on('disconnect', (_) => print('Disconnected'));

      // Return the future from the Completer
      return completer.future;
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  Future<void> saveUserDataLocally(User user) async {
    // await _secureStorage.write(key: 'user', value: jsonEncode(user));

    try {
      String userData = jsonEncode(user.toJson()); // Use toJson method
      await _secureStorage.write(key: 'user', value: userData);
      print('Data saved to secure storage (user)');
    } catch (e) {
      print('Error saving data to secure storage: $e');
    }
    // await _secureStorage.write(key: 'user_name', value: user.name);
    // await _secureStorage.write(key: 'user_email', value: user.email);
    // await _secureStorage.write(key: 'user_photoUrl', value: user.photoUrl);
    // await _secureStorage.write(key: 'user_id', value: user.id);
  }

  // Future<User> getUserDetails(GoogleSignInAccount googleUser,
  //     GoogleSignInAuthentication googleAuth) async {
  //   // Extract user data from GoogleSignInAccount
  //   final String displayName = googleUser.displayName ?? '';
  //   final String email = googleUser.email ?? '';
  //   final String photoUrl = googleUser.photoUrl ?? '';
  //   final String id = googleUser.id ?? '';

  //   // Create User object
  //   final User currentUser = User(
  //     name: displayName,
  //     email: email,
  //     photoUrl: photoUrl,
  //     id: id,
  //   );

  //   //       print('Connected to Socket.io server!');
  //   // socket = IO.io('http://localhost:3000' , <String, dynamic>{
  //   // socket = IO.io('http://192.168.1.13:8080', <String, dynamic>{
  //   //   'transports': ['websocket'],
  //   //   "autoConnect": false, // Specify transport (optional)
  //   // });
  //   // socket.connect();
  //   // socket.on('connect', (_) => print('Connected'));

  //   // print('Connected to Socket.io server!');
  //   // print(googleUser);
  //   // // final userJson = jsonEncode(currentUser.toJson());
  //   // socket.emit('chat_message', googleUser.toString());
  //   // socket.on('disconnect', (_) => print('Disconnected'));
  //   return currentUser;
  // }

  Future<bool> googleSignout() async {
    // await auth.signOut();
    await _googleSignIn.signOut().then((value) {
      print(value?.displayName);
    });
    return true;
  }

  //   Future<bool> login(String username, String password) async {
  //   // Implement your login logic using Socket.io events
  //   // You'll need to define events on your server to handle login requests
  //   // and send responses with success/failure information

  //   Map<String, dynamic> loginData = {'username': username, 'password': password};

  //   try {
  //     socket.emit('login', loginData); // Emit a login event with user credentials

  //     socket.on('login_response', (data) {
  //       // Handle login response from the server
  //       if (data['success'] == true) {
  //         await secureStorage.write(key: "user", value: data['user']);
  //         // Store additional user data received from the server (optional)
  //         return true;
  //       } else {
  //         print(data['message']); // Handle login failure message
  //         return false;
  //       }
  //     });

  //     // Add a timeout mechanism to handle cases where the server doesn't respond (optional)

  //     return true; // Indicate login attempt initiated (waiting for server response)
  //   } catch (e) {
  //     print('Error during login: $e');
  //     return false;
  //   }
  // }

  // Future<bool> logout() async {
  //   // Implement your logout logic using Socket.io events
  //   // You'll need to define an event on your server to handle logout requests

  //   try {
  //     socket.emit('logout'); // Emit a logout event

  //     await secureStorage.delete(key: "user");
  //     // Clear any other stored user data (optional)

  //     return true;
  //   } catch (e) {
  //     print('Error during logout: $e');
  //     return false;
  //   }
  // }

  // Future<Map<String, dynamic>?> getUserData() async {
  //   String? userId = await secureStorage.read(key: "user");
  //   if (userId == null) return null;

  //   // Implement your logic to retrieve user data using Socket.io events
  //   // You'll need to define an event on your server to handle user data requests

  //   try {
  //     socket.emit('get_user_data', {'userId': userId}); // Emit a request for user data

  //     socket.on('user_data_response', (data) {
  //       // Handle user data response from the server
  //       if (data['success'] == true) {
  //         return data['user']; // Return received user data
  //       } else {
  //         print(data['message']); // Handle data retrieval failure message
  //         return null;
  //       }
  //     });

  //     // Add a timeout mechanism to handle cases where the server doesn't respond (optional)

  //     return null; // Indicate data request initiated (waiting for server response)
  //   } catch (e) {
  //     print('Error retrieving user data: $e');
  //     return null;
  //   }
  // }
}
