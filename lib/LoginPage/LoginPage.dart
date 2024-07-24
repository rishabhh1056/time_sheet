
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_sheet/LoginPage/LoginAsHr.dart';
import 'package:time_sheet/adminDashboard/adminDashboard.dart';

import '../firebaseAuth/FirebaseAuth.dart';
import '../massage/MassageHandler.dart';
import '../userDashboard/userDashboard.dart';
import 'LoginAsManager.dart';


class EmployeLoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<EmployeLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  String? email;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }



  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      User? user = await _auth.SigninWithEmailAndPassword(savedEmail, savedPassword);
      if (user != null) {
        setState(() {
          email = savedEmail;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDashboard(userEmail: email!),
          ),
        );
      }
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      User? user = await _auth.SigninWithEmailAndPassword(username, password);

      int? isAdmin;

      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("EmployeeDetails")
            .doc(username)
            .get();

        if (documentSnapshot.exists && documentSnapshot.get("admin") != null) {
          isAdmin = documentSnapshot.get("admin");
        }
      } catch (e) {
        print('Error fetching data: $e');
      }

      if (user != null) {
        if (isAdmin == 1) {
          MessageHandler.showLoginFailed();
        } else {
          email = username;
          MessageHandler.showLoginSuccess();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', username);
          await prefs.setString('password', password);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDashboard(userEmail: email!),
            ),
          );
        }
      } else {
        MessageHandler.showLoginFailed();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1D1F4),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black, size: 30,),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text("Login As Employee", style: TextStyle(fontWeight: FontWeight.w400),)
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Login with \nUsername and password',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 80),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF11359A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _login,
                    child: Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login as Manager',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            IconButton(icon: Icon(Icons.arrow_circle_right) , onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> ManagerLoginScreen()));  },),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login as Human Resources',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            IconButton(icon: Icon(Icons.arrow_circle_right) , onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> HrLoginScreen())); },),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}



Future<int> fetchData(String docsID) async {
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("EmployeeDetails")
        .doc(docsID)
        .get();

    if (documentSnapshot.exists && documentSnapshot.get("admin") != null) {
      int isAdmin = documentSnapshot.get("admin");
      return isAdmin;
    } else {
      return 0;
    }
  } catch (e) {
    print('Error fetching data: $e');
    return 0;
  }
}
