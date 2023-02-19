import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {

  static const String id = 'chat_screen';
  String uniqueKey;
  String receiverEmail;

  ChatScreen({this.uniqueKey, this.receiverEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String msgText;

  void getCurrentUser() {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        print(FirebaseAuth.instance.currentUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void messageStream() async {
  //   await for (var snapshot in FirebaseFirestore.instance.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 2,
        leading: null,
        title: ListTile(
          horizontalTitleGap: 7,
          contentPadding: EdgeInsets.all(0),
          leading: Icon(Icons.account_circle_rounded,size: 50,),
          title: Text(widget.receiverEmail.substring(0, widget.receiverEmail.indexOf('@')),style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(widget.uniqueKey),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
              child: Card(
                shape: StadiumBorder(),
                // decoration: kMessageContainerDecoration,
                elevation: 2,
                color: Colors.blueGrey.shade50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          msgText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageTextController.clear();
                        FirebaseFirestore.instance
                            .collection('globalMessages')
                            .doc(widget.uniqueKey)
                            .get()
                            .then((docSnapshot) => {
                                  if (docSnapshot.exists)
                                    {
                                      FirebaseFirestore.instance
                                          .collection('globalMessages')
                                          .doc(widget.uniqueKey)
                                          .collection('messages')
                                          .add({
                                        'sender': FirebaseAuth.instance.currentUser.email,
                                        'text': msgText,
                                        'timestamp': FieldValue.serverTimestamp(),
                                      })
                                    }
                                  else
                                    {
                                      FirebaseFirestore.instance
                                          .collection('globalMessages')
                                          .doc(widget.uniqueKey)
                                          .set({}).then((docSnapshot) => {
                                                FirebaseFirestore.instance
                                                    .collection('globalMessages')
                                                    .doc(widget.uniqueKey)
                                                    .collection('messages')
                                                    .add({
                                                  'sender':
                                                      FirebaseAuth.instance.currentUser.email,
                                                  'text': msgText,
                                                  'timestamp': FieldValue
                                                      .serverTimestamp(),
                                                })
                                              })
                                    }
                                });
                        // FirebaseFirestore.instance.collection('globalMessages').doc(widget.uniqueKey).collection('messages').add({
                        //   'sender': FirebaseAuth.instance.currentUser.email,
                        //   'text': msgText,
                        //   'timestamp': FieldValue.serverTimestamp(),
                        // });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  final timestamp;

  MessageBubble({this.text, this.sender, this.isMe, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 2),
          //   child: Text(
          //     '$sender',
          //     style: TextStyle(
          //       fontSize: 12,
          //       color: Colors.black54,
          //     ),
          //   ),
          // ),
          Material(
            borderRadius: BorderRadius.only(
                topLeft: isMe ? Radius.circular(18) : Radius.circular(0),
                topRight: isMe ? Radius.circular(0) : Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18)),
            elevation: 0,
            color: isMe ? Colors.lightBlueAccent : Colors.blueGrey.shade100,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              child: Text(
                '$text',
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  String uniqueKey;

  MessageStream(this.uniqueKey);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('globalMessages')
            .doc(uniqueKey)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message['text'];
            final messageSender = message['sender'];

            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: (FirebaseAuth.instance.currentUser.email == messageSender),
              timestamp: FieldValue.serverTimestamp(),
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 4),
              children: messageBubbles,
            ),
          );
        });
  }
}
