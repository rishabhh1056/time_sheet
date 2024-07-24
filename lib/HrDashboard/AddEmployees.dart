import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_sheet/color/AppColors.dart';

import '../firebaseAuth/FirebaseAuth.dart';
import '../massage/MassageHandler.dart';

class EmployeeForm extends StatefulWidget {
  final String? employeeId;

  EmployeeForm({this.employeeId});

  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _profileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String? _userName;
  String? _imageUrl;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  //firebase
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    if (widget.employeeId != null) {
      _loadEmployeeDetails();
    }
  }

  Future<void> _loadEmployeeDetails() async {
    var doc = await FirebaseFirestore.instance.collection('EmployeeDetails').doc(widget.employeeId).get();
    var data = doc.data() as Map<String, dynamic>;

    setState(() {
      _userNameController.text = data['user Name'];
      _phoneNumberController.text = data['phone'];
      _addressController.text = data['address'];
      _profileController.text = data['user Profile'];
      _emailController.text = data['email'];
      _imageUrl = data['imageUrl'];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // await _uploadImageToFirebase();
    }
  }

  // Future<void> _uploadImageToFirebase() async {
  //   String fileName = _emailController.text;
  //   Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
  //   UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
  //   TaskSnapshot taskSnapshot = await uploadTask;
  //   String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //   setState(() {
  //     _imageUrl = downloadUrl;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text(widget.employeeId == null ? 'Add Employee' : 'Edit Employee', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : AssetImage('assets/images/user.png')
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: Icon(Icons.camera_alt, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _userNameController,
                  labelText: 'User Name',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _phoneNumberController,
                  labelText: 'Phone Number',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _addressController,
                  labelText: 'Address',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _profileController,
                  labelText: 'Profile',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.0),
                if (widget.employeeId == null) ...[
                  _buildTextFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: 20.0),
                ],
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.userPrimaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(MediaQuery.sizeOf(context).width * 9.40, 40)),
                  child: Text(
                    widget.employeeId == null ? 'Add Employee' : 'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // All fields are valid, perform data submission
      if (widget.employeeId == null) {
        _addEmployee();
      } else {
        _updateEmployee();
      }
    } else {
      // Validation failed, show error toast
      MessageHandler.fillAllDetails();
    }
  }

  Future<void> _addEmployee() async {
    String userName = _userNameController.text;
    String profile = _profileController.text;
    String userEmail = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.SignUpWithEmailAndPassword(userEmail, password);

    var uid = user?.uid;

    if (user != null) {
      FirebaseFirestore.instance.collection('EmployeeDetails').doc(userEmail).set({
        "user Name": userName,
        "user Profile": profile,
        "email": userEmail,
        "password": password,
        "uid": uid,
        "admin": 0,
        "imageUrl": _imageUrl,
      }).then((value) {
        MessageHandler.EmployeAdded();

        _userNameController.clear();
        _profileController.clear();
        _emailController.clear();
        _passwordController.clear();
      }).catchError((error) {
        MessageHandler.EmployeAddedFailed(error);
      });
    } else {
      MessageHandler.EmployeAddedFailed("");
    }
  }

  Future<void> _updateEmployee() async {
    String userName = _userNameController.text;
    String profile = _profileController.text;
    String userEmail = _emailController.text;

    await FirebaseFirestore.instance.collection('EmployeeDetails').doc(widget.employeeId).update({
      "user Name": userName,
      "user Profile": profile,
      "email": userEmail,
      "imageUrl": _imageUrl,
    }).then((value) {
      MessageHandler.showCustomMessage("employee updated", backgroundColor: Colors.green);

      Navigator.pop(context);
    }).catchError((error) {
      MessageHandler.showCustomMessage("employee updated failed", backgroundColor: Colors.red);
    });
  }
}
