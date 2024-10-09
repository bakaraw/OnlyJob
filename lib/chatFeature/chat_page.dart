import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:only_job/chatFeature/displayMessage.dart';
import 'package:only_job/views/constants/constants.dart';

import '../models/message.dart';
import '../services/auth.dart';
import 'chatList.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthService authService = AuthService();

  String? currentUserName;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserName();
  }

  void fetchCurrentUserName() async {
    currentUserName = await authService.getCurrentUserName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String receiverName = widget.user['name'] ?? 'Unknown';
    String receiverUserId = widget.user['uid'] ?? ''; // Ensure this is the receiver's UID

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['name'] ?? 'Unknown', style: usernameStyle,),
        actions: [
          IconButton(
            color: Colors.blueAccent,
            onPressed: () {
            },
            icon: Icon(Icons.menu_open, color: primarycolor,),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display messages for the chat
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: DisplayMessage(
                user: receiverName,
                receiverUserId: receiverUserId,
                senderUserId: auth.currentUser?.uid ?? '',
                // Pass the receiver user ID
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Message",
                        contentPadding: EdgeInsets.only(left: 15, bottom: 8, top: 8),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primarycolor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primarycolor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        messageController.text = value!;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (messageController.text.isNotEmpty) {



                        // Create the message object
                        Message newMessage = Message(
                          message: messageController.text.trim(),
                          time: DateTime.now(),
                          senderName: currentUserName ?? 'Unknown',
                          senderId: auth.currentUser?.uid ?? '',
                          receiver: receiverName,
                        );

                        String currentUserId = auth.currentUser?.uid ?? '';
                        String receiverUserId = widget.user['uid'] ?? '';

                        // Add the message to both the receiver's and sender's message subcollections
                        DocumentReference receiverDocRef = firebaseFirestore
                            .collection('User')
                            .doc(receiverUserId)
                            .collection('messages')
                            .doc(currentUserId);

                        DocumentReference senderDocRef = firebaseFirestore
                            .collection('User')
                            .doc(currentUserId)
                            .collection('messages')
                            .doc(receiverUserId);

                        try {
                          // Send the message to both users
                          await receiverDocRef.collection('chatMessages').add(newMessage.toMap());
                          await senderDocRef.collection('chatMessages').add(newMessage.toMap());

                          // Update the sender's contacts and the receiver's pending list
                          await firebaseFirestore.collection('User').doc(currentUserId).set({
                           'contacts': FieldValue.arrayUnion([receiverUserId]), // Add to sender's contacts
                          }, SetOptions(merge: true));

                      //    await firebaseFirestore.collection('User').doc(receiverUserId).set({
                       //     'contacts': FieldValue.arrayUnion([currentUserId]), // Add to sender's contacts
                        //  }, SetOptions(merge: true));


                          await firebaseFirestore.collection('User').doc(receiverUserId).set({
                            'pending': FieldValue.arrayUnion([currentUserId]), // Add sender to receiver's pending
                          }, SetOptions(merge: true));


                          // Clear the message input
                          messageController.clear();
                        } catch (e) {
                          print('Error sending message: $e');
                        }
                      }
                    },
                    icon: Icon(Icons.send, size: 30, color: primarycolor),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}