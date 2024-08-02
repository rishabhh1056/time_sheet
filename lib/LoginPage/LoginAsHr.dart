
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:time_sheet/HrDashboard/HrDashboard.dart';
import '../firebaseAuth/FirebaseAuth.dart';
import '../massage/MassageHandler.dart';

class HrLoginScreen extends StatefulWidget {
  @override
  _HrLoginScreenState createState() => _HrLoginScreenState();
}

class _HrLoginScreenState extends State<HrLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  String? email;

  @override
  void initState() {
    super.initState();
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
                        icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Login As Human Resources",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: AssetImage('assets/images/hr.jpg'), // Add your image path here
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF11359A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: loginData,
                            child: Text(
                              'Login',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
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

  Future<void> loginData() async {

    // API URL
    String url = 'https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/login';

    // Create the request body
    Map<String, String> requestBody = {
      'email': _usernameController.text,
      'password': _passwordController.text,
    };

    print(_usernameController.text);
    print(_passwordController.text);


    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {

        if(jsonResponse['message'] == 'Login successful'){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HrDashboard()));
        }
        // If the server returns a 200 OK response
        MessageHandler.showCustomMessage(jsonResponse['message'],backgroundColor: Colors.green);
      } else {
        // If the server did not return a 200 OK response
        MessageHandler.showCustomMessage(jsonResponse['message'],backgroundColor: Colors.red);
      }
    } catch (error) {
      // Handle any errors that occur during the request
      MessageHandler.somethingWentWrong();
      print(error);
    }
  }





  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

