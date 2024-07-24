import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'IntroScreen/IntroScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBy66B8uD3fhC6d-4O9ivDTNC613eUeEgc',
        appId: '1:672092785059:android:b626481bba5382c8ffb216',
        messagingSenderId: 'messagingSenderId',
        projectId: 'fir-4d737',
        storageBucket: 'fir-4d737.appspot.com',   ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF092E83),
      ),
      home: IntroPage(),
    );
  }
}



