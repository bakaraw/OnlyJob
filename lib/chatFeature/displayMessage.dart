import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:only_job/views/constants/constants.dart';
import 'package:only_job/views/constants/loading.dart';

import '../models/message.dart';
import '../services/auth.dart';

class DisplayMessage extends StatefulWidget {
  final String user; // Receiver's name
  final String receiverUserId; // Receiver's user ID
  final String senderUserId; // Sender's user ID
  const DisplayMessage({super.key, required this.user, required this.receiverUserId, required this.senderUserId});

  @override
  State<DisplayMessage> createState() => _DisplayMessageState();
}

class _DisplayMessageState extends State<DisplayMessage> {
  late final Stream<List<Message>> messageStream;
  final AuthService authService = AuthService();
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserName();
    _getMessages();
  }

  void fetchCurrentUserName() async {
    currentUserName = await authService.getCurrentUserName();
    setState(() {});
  }

  void _getMessages() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    messageStream = FirebaseFirestore.instance
        .collection('User')
        .doc(currentUserId)
        .collection('messages')
        .doc(widget.receiverUserId)
        .collection('chatMessages')
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<String?> getProfilePicture(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data();
        return userData?['profile_picture'];
      } else {
        return null; // Return null if user does not exist
      }
    } catch (e) {
      print('Error getting profile picture: $e');
      return null; // Handle errors by returning null
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: messageStream,
      builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
        // Error handling
        if (snapshot.hasError) {
          return Center(child: Text("An error occurred", style: errortxtstyle));
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Loading());
        }

        // Check if there are no messages
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text("No messages found", style: usernameStyle));
        }

        // Building the message list
        return ListView.builder(
          itemCount: snapshot.data!.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            Message message = snapshot.data![index];

            // Determine if the current message is sent by the user or received from another user
            bool isSender = message.senderId == widget.senderUserId; // Use senderId for comparison

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300, // Limit the width of each ListTile
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: primarycolor),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          tileColor: isSender ? secondarycolor : Colors.white,
                          leading: FutureBuilder<String?>(
                            future: isSender
                                ? getProfilePicture(widget.senderUserId) // Sender's profile picture
                                : getProfilePicture(widget.receiverUserId), // Receiver's profile picture
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                //return Loading();
                                return CircularProgressIndicator(); // Display loading indicator
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                return CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot.data!),
                                ); // Display profile picture
                              } else {
                                return CircleAvatar(
                                  child: Icon(Icons.person),
                                ); // Default avatar
                              }
                            },
                          ),
                          title: Text(
                            isSender ? message.senderName : widget.user,
                            style: usernameStyle,
                            textAlign: TextAlign.left, // Align the text to the left
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message.message,
                                  softWrap: true,
                                  style: TextStyle(fontSize: 15, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8), // Add space between ListTile and time
                      Text(
                        '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
