import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'package:http/http.dart' as http;

class EmployeeForm extends StatefulWidget {

@override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _perHoursController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _profileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmationController = TextEditingController();

  String? _userName;
  String? _imageUrl;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Static roles list
  String? _selectedRole; // Variable to store selected role
  List<Map<String, dynamic>> roles = [
    {'Employee': 1},
    {'Manager': 2},
    {'HR': 3},
    // Add more roles as needed
  ];

  bool _isLoading = false;
  int? _selectedRoleCode;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print("No image selected");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _onRoleChanged(String? newValue) {
    setState(() {
      _selectedRole = newValue;

      if (newValue != null) {
        var selectedRole = roles.firstWhere(
                (role) => role.containsKey(newValue),
            orElse: () => {}
        );

        _selectedRoleCode = selectedRole.values.isNotEmpty
            ? selectedRole.values.first
            : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Add Employee', style: TextStyle(color: Colors.white)),
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
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _profileController,
                  labelText: 'Profile',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _addressController,
                  labelText: 'Address',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                    controller: _phoneNumberController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.numberWithOptions(),
                    length: 10
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                    controller: _perHoursController,
                    labelText: 'Per hour cost',
                    keyboardType: TextInputType.numberWithOptions(),
                    length: 10
                ),
                SizedBox(height: 16.0),
                _buildRoleDropdown(),
                SizedBox(height: 16.0),

                  _buildTextFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.userPrimaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(MediaQuery.sizeOf(context).width * 0.9, 40)),
                  child: Text(
                     'Add Employee',
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
    int length = 256,
    int maxLines = 1
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: length,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        counterText: '',
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

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Role',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
      ),
      items: roles.map((Map<String, dynamic> role) {
        String roleName = role.keys.first;
        return DropdownMenuItem<String>(
          value: roleName,
          child: Text(roleName),
        );
      }).toList(),
      onChanged: _onRoleChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select a role';
        }
        return null;
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/user/store'), // Replace with your API URL
        );

        request.headers['Content-Type'] = 'multipart/form-data';

        // Add text fields
        request.fields['name'] = _userNameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _passwordController.text;
        // request.fields['password_confirmation'] = _passwordConfirmationController.text;
        request.fields['profile'] = _profileController.text;
        request.fields['contact'] = _phoneNumberController.text;
        request.fields['per_hour_cost'] = _perHoursController.text;
        request.fields['address'] = _addressController.text;
        request.fields['status_code'] = _selectedRoleCode.toString();

        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'imageUrl',
            _image!.path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }

        // Log the request fields and headers
        print('Request Fields: ${request.fields}');
        print('Request Headers: ${request.headers}');

        var response = await request.send();
        print('Response Status Code: ${response.statusCode}');
        var responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Employee added successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add employee: $responseBody')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

}
