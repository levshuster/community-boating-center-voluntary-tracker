// --- login Pop-up ---

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget buildWelcomeDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Welcome'),
    content: const Text(
        'Thank you for helping us keep track of our boats! Please sign in to continue. Once you launch, start your trip. When you return, end your trip. Thank you!'),
    actions: <Widget>[
      OutlinedButton(
        child: const Text('Sign In With Apple'),
        onPressed: () async {
          // await signInWithGoogle();
          Navigator.of(context).pop();
        },
      ),
      OutlinedButton(
        child: const Text('Sign In With Google'),
        onPressed: () async {
          await signInWithGoogle();
          // print(FirebaseAuth.instance.currentUser?.email);
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

Future<UserCredential> signInWithGoogle() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
  return userCredential;
}

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
}
