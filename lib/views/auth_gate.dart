import 'package:flutter/material.dart';
import 'package:only_job/views/authenticate/register_or_login.dart';
import 'package:only_job/views/home/home.dart';
import 'package:provider/provider.dart';
import 'package:only_job/models/user.dart';
import 'dart:developer';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    log(user.toString());
    if (user != null) {
      return Home(uid: user.uid!);
      //return Test();
    } else {
      return RegisterLogin();
    }
  }
}
