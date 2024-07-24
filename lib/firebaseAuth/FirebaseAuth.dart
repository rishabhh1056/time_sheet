

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseAuthService {




  Future<User?> SignUpWithEmailAndPassword(String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
      // Return the user after successful creation
    } catch (e) {
      print('Error registering user: $e');
      return null; // Return null or handle the error as per your app's logic
    }
  }


  Future<User?> SigninWithEmailAndPassword(String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("login Successful...............");
      return credential.user; // Return the user after successful creation
    } catch (e) {
      print('Error registering user: $e');
      return null; // Return null or handle the error as per your app's logic
    }
  }

}