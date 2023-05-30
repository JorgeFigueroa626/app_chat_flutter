
import 'package:app_chat/Authenticate/login_screen.dart';
import 'package:app_chat/Screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Authenticate extends StatelessWidget {
  Authenticate({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return const HomeScreen();
    } else {
      return const LoginScreeen();
    }
  }
}
