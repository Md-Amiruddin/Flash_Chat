import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/globals.dart';

var _auth = FirebaseAuth.instance;
var _firestore = FirebaseFirestore.instance;
final SnackBar snackBar = SnackBar(content: Text("User does not exist"));

class AddChatScreen extends StatelessWidget {
  static const String id = 'add_chat_screen';
  String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: ('Enter email'),
            ),
            onChanged: (value) {
              email = value;
            },
          ),
          SizedBox(height: 10,),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              List<String> listOfSignInMethods = [];
              listOfSignInMethods = await _auth.fetchSignInMethodsForEmail(email);
              if(email == null || listOfSignInMethods.isEmpty) {
                snackbarKey.currentState?.showSnackBar(snackBar);
                // var snackBar = SnackBar(content: Text('User does not exist'));
                // ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              else if(listOfSignInMethods.isNotEmpty){
                String docId;
                await _firestore.collection('users').doc(_auth.currentUser.email).collection('connections').doc(email).set({});
                await _firestore.collection('users').doc(_auth.currentUser.email).collection('connections').doc(email).collection('uniqueKey').add({}).then((docSnap) {docId = docSnap.id;});

                print("docId = $docId");

                await _firestore.collection('users').doc(email).collection('connections').doc(_auth.currentUser.email).set({});
                await _firestore.collection('users').doc(email).collection('connections').doc(_auth.currentUser.email).collection('uniqueKey').doc(docId).set({});
              }
            },
            child: Text('Add to Chat',
            style: TextStyle(
              color: Colors.white,
            ),),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.lightBlueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
