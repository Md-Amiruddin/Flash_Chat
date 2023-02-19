import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'add_chat_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  static const String id = "chat_room_screen";

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                widget._auth.signOut();
                Navigator.pop(context);
              }),
        ],
        elevation: 2,
        backgroundColor: Colors.lightBlueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context, builder: (context) => AddChatScreen());
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget._firestore
            .collection('users')
            .doc(widget._auth.currentUser.email)
            .collection('connections').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final users = snapshot.data.docs;
          List<ChatTile> listOfChats = [];
          for (dynamic user in users) {
            if(user.id == widget._auth.currentUser.email) continue;
            listOfChats.add(ChatTile(email: user.id,));
          }

          return listOfChats.isNotEmpty
          ? ListView(
            children: listOfChats,
          )
              : Center(child: Text('Tap on the + button to start a chat'),);
        },
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String email;

  ChatTile({@required this.email});

  Future<String> getUniqueKey() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('connections')
        .doc(email)
        .collection('uniqueKey')
        .get()
        .then((querySnapshot) => querySnapshot.docs[0].id);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 8,
      minVerticalPadding: 25,
      leading: Icon(
        Icons.account_circle_rounded,
        size: 50,
      ),
      title: Text(
        email,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () async {
        String uniqueKey = await getUniqueKey();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      uniqueKey: uniqueKey,
                      receiverEmail: email,
                    )));
      },
    );
  }
}
