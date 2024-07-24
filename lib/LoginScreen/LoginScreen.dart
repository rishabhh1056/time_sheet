import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:time_sheet/adminDashboard/adminDashboard.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'package:time_sheet/firebaseAuth/FirebaseAuth.dart';
import 'package:time_sheet/userDashboard/userDashboard.dart';

import '../massage/MassageHandler.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();

  void _login() async{
    if (_formKey.currentState!.validate()) {


      // Validation passed, perform login logic
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      // Replace this with your authentication logic (e.g., Firebase Auth)
      // For demonstration, just print the username and password
      print('Username: $username');
      print('Password: $password');

      User? user = await _auth.SigninWithEmailAndPassword(username, password);

      int? isAdmin;

      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("EmployeeDetails")
            .doc(username)
            .get();

        // Check if the 'admin' field exists and is not null
        if (documentSnapshot.exists && documentSnapshot.get("admin") != null) {
           isAdmin = documentSnapshot.get("admin");
        }

      } catch (e) {
        print('Error fetching data: $e');

      }

      print("$isAdmin========================================================");
      

      if(user!= null)
        {
         if(isAdmin == 1) {
           MessageHandler.showLoginSuccess();
           Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
           }
         else{
           MessageHandler.showLoginFailed();
           // Navigator.push(context, MaterialPageRoute(builder: (context) => UserDashboard()));
         }

        }
      else{
        MessageHandler.showLoginFailed();
      }


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page', style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.AdminThemePrimary,
        // leading: Icon(Icons.arrow_back),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
        
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('Login as \nAdmin', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),),
                ),
                SizedBox(height: 80,),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
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
        
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.AdminThemePrimary,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),minimumSize: Size(MediaQuery.sizeOf(context).width *9.40, 40)),
                  onPressed: _login,
                  child: Text('Login', style: TextStyle(color: Colors.white),),
                ),
              ],
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

    // Check if the 'admin' field exists and is not null
    if (documentSnapshot.exists && documentSnapshot.get("admin") != null) {
      int isAdmin = documentSnapshot.get("admin");
      return isAdmin;
    } else {
      // Handle case where 'admin' field doesn't exist or is null
      // You can return a default value or throw an error, depending on your use case
      return 0; // Example default value
    }

  } catch (e) {
    print('Error fetching data: $e');
    // Handle error or return a default value
    return 0; // Example default value
  }
}