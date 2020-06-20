import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
//import 'package:chat/models/user_details.dart';
import 'package:chat/screens/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference collectionReference = Firestore.instance.collection("users");
  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  /*DocumentReference _documentReference;
  UserDetails _userDetails = UserDetails();
  var mapData = Map<String, String>();
  String uid;*/


  /*Future<FirebaseUser> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
    await _signInAccount.authentication;

    AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: _signInAuthentication.idToken,
        accessToken: _signInAuthentication.accessToken);

    FirebaseUser user = (await _firebaseAuth.signInWithCredential(authCredential)).user;
    return user;
  }

  void addDataToDb(FirebaseUser user) {
    _userDetails.name = user.displayName;
    _userDetails.emailId = user.email;
    _userDetails.photoUrl = user.photoUrl;
    _userDetails.uid = user.uid;
    mapData = _userDetails.toMap(_userDetails);

    uid = user.uid;

    _documentReference = Firestore.instance.collection("users").document(uid);

    _documentReference.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Users()));
      } else {
        _documentReference.setData(mapData).whenComplete(() {
          print("Users Colelction added to Database");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Users()));
        }).catchError((e) {
          print("Error adding collection to Database $e");
        });
      }
    });
  }*/
  Future signUpWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken
      );

      AuthResult authResult = await _auth.signInWithCredential(authCredential);
      FirebaseUser user = authResult.user;
      _checkExistUserFromFirebaseDB(user);
      return user;
    } catch(e) {
      showDialogWithText(e.message);
    }

  }

  Future _checkExistUserFromFirebaseDB(FirebaseUser firebaseUser) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result =
        await collectionReference.where('id', isEqualTo: firebaseUser.uid).getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Users()),
          );
        } else {
          // Write data to local
          await prefs.setString('uid', documents[0]['uid']);
          await prefs.setString('emailID', documents[0]['emailID']);
          await prefs.setString('name', documents[0]['name']);
          await prefs.setString('photoUrl', documents[0]['photoUrl']);
          await prefs.setBool('isLogin', true);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Users()),
          );
        }
        //widget.parentAction(false);
      } else {
        showDialogWithText('No user id');
        //widget.parentAction(false);
      }
    }catch(e) {
      showDialogWithText(e.message);
    }
  }

  showDialogWithText(String textMessage) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(textMessage),
          );
        }
    );
    //widget.parentAction(false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ChatApp'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Chat App',
              style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
            ),
            RaisedButton(
              elevation: 8.0,
              padding: EdgeInsets.all(8.0),
              shape: StadiumBorder(),
              textColor: Colors.black,
              color: Colors.lime,
              child: Text('Sign In'),
              splashColor: Colors.red,
              onPressed: () {
                signUpWithGoogle();
              },
            )
          ],
        ),
      ),
    );
  }
}
