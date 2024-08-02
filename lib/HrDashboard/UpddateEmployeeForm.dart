import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'package:http/http.dart' as http;

import '../massage/MassageHandler.dart';

class UpdateEmployeeForm extends StatefulWidget {
  final int projectId;
  UpdateEmployeeForm({required this.projectId});
  @override
  _UpdateEmployeeFormState createState() => _UpdateEmployeeFormState();
}

class _UpdateEmployeeFormState extends State<UpdateEmployeeForm> {
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

  String? _selectedRoleCode;
  late Map<String, dynamic> _projectsData;

  Future<void> _fetchEmployeeDetail() async {
    try {
      var response = await http.get(Uri.parse(
          'https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/user/${widget
              .projectId}'));
      var jsonResponse = json.decode(response.body);

      print('response:   ---------${response.body}');
      print('jsonResponse:   ---------${jsonResponse[0]}');

      if (jsonResponse[0]['ststus'] == 1) {
        setState(() {
          _projectsData = jsonResponse[0]['user'];
          print(_projectsData);

          _userNameController.text = _projectsData['name'] ?? '';
          _emailController.text = _projectsData['email'] ?? '';
          _profileController.text = _projectsData['profile'] ?? '';
          _addressController.text = _projectsData['address'] ?? '';
          _phoneNumberController.text = _projectsData['contact'] ?? '';
          _perHoursController.text = _projectsData['per_hour_cost'] ?? '';
          _selectedRoleCode = _projectsData['status_code'] ?? "";
          _passwordController.text = _projectsData['password'] ?? '';
          _passwordConfirmationController.text =
              _projectsData['assign_manager'] ?? '';

          // Automatically select the role
          var roleEntry = roles.firstWhere(
                (role) => role.values.first.toString() == _selectedRoleCode,
            orElse: () => {},
          );
          if (roleEntry.isNotEmpty) {
            _selectedRole = roleEntry.keys.first;
          }
        });
      } else {
        MessageHandler.showCustomMessage(
            jsonResponse[0]['message'], backgroundColor: Colors.red);
      }
      print(_projectsData);
    } catch (e) {
      MessageHandler.showCustomMessage(
          'Something went wrong: $e', backgroundColor: Colors.red);
      print(e);
    }
  }

  @override
  void initState() {
    _fetchEmployeeDetail();
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
          orElse: () => {},
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
        title: Text('Update Employee', style: TextStyle(color: Colors.white)),
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
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.userPrimaryColor,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _profileController,
                  decoration: InputDecoration(
                    labelText: 'Profile',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a profile';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _perHoursController,
                  decoration: InputDecoration(
                    labelText: 'Per Hour Cost',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the per hour cost';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildRoleDropdown(),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.userPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Update Employee',
                        style: TextStyle(fontSize: 15.0, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          'PUT',
          Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/user/update/${widget.projectId}'),
        );

        request.headers['Content-Type'] = 'multipart/form-data';

        // Add text fields
        request.fields['name'] = _userNameController.text.trim();
        request.fields['email'] = _emailController.text.trim();
        if (_passwordController.text.isNotEmpty) {
          request.fields['password'] = _passwordController.text.trim(); // Only include password if it's not empty
        }
        request.fields['profile'] = _profileController.text.trim();
        request.fields['contact'] = _phoneNumberController.text.trim();
        request.fields['per_hour_cost'] = _perHoursController.text.trim();
        request.fields['address'] = _addressController.text.trim();
        request.fields['status_code'] = _selectedRoleCode.toString().trim();

        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'imageUrl',
            _image!.path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
         print(_userNameController.text.trim());
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Employee updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update employee: $responseBody')),
          );
          print(responseBody);
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
