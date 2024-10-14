import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:only_job/chatFeature/user_search.dart';
import 'package:only_job/views/constants/constants.dart';
import 'chat_list.dart';
import 'chat_page.dart';

class MainChatPage extends StatefulWidget {
  const MainChatPage({super.key});

  @override
  State<MainChatPage> createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundwhite,
      body: UserListPage(
        user: '',
        receiverUserId: '',
      ),
    );
  }
}
