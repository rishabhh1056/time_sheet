import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../color/AppColors.dart';
import 'AddEmployees.dart';

class UpdateEmployeePage extends StatefulWidget {
  @override
  _UpdateEmployeePageState createState() => _UpdateEmployeePageState();
}

class _UpdateEmployeePageState extends State<UpdateEmployeePage> {
  List<Map<String, dynamic>> _employeeData = [
    {
      'id': '1',
      'imageUrl': 'https://img.freepik.com/free-photo/smiley-businesswoman-posing-city-with-arms-crossed_23-2148767033.jpg?size=626&ext=jpg&ga=GA1.1.489158364.1721033273&semt=ais_user',
      'user Name': 'John Doe',
      'user Profile': '123 Main St',
      'phone': '123-456-7890',
      'email': 'johndoe@example.com',
    },
    {
      'id': '2',
      'imageUrl': 'https://img.freepik.com/free-photo/modern-businesswoman-with-arms-crossed_23-2147716875.jpg?size=626&ext=jpg&ga=GA1.1.489158364.1721033273&semt=ais_user',
      'user Name': 'Jane Smith',
      'user Profile': '456 Elm St',
      'phone': '987-654-3210',
      'email': 'janesmith@example.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Update Employee', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: ListView.builder(
        itemCount: _employeeData.length,
        itemBuilder: (context, index) {
          var employee = _employeeData[index];

          return Card(
            margin: EdgeInsets.all(10.0),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(employee['imageUrl'] ?? 'https://via.placeholder.com/150'),
              ),
              title: Text(employee['user Name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address: ${employee['user Profile']}'),
                  Text('Phone: ${employee['phone']}'),
                  Text('Email: ${employee['email']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to the edit page
                      EmployeeForm(employeeId: employee['id'],);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteEmployee(employee['id']);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _editEmployee(BuildContext context, String employeeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmployeeForm(employeeId: employeeId, employeeData: _employeeData),
      ),
    );
  }

  void _deleteEmployee(String employeeId) {
    setState(() {
      _employeeData.removeWhere((employee) => employee['id'] == employeeId);
    });
    Fluttertoast.showToast(msg: 'Employee deleted successfully');
  }
}

class EditEmployeeForm extends StatefulWidget {
  final String employeeId;
  final List<Map<String, dynamic>> employeeData;

  EditEmployeeForm({required this.employeeId, required this.employeeData});

  @override
  _EditEmployeeFormState createState() => _EditEmployeeFormState();
}

class _EditEmployeeFormState extends State<EditEmployeeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _profileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String? _imageUrl;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadEmployeeDetails();
  }

  void _loadEmployeeDetails() {
    var employee = widget.employeeData.firstWhere((employee) => employee['id'] == widget.employeeId);

    setState(() {
      _userNameController.text = employee['user Name'];
      _phoneController.text = employee['phone'];
      _addressController.text = employee['user Profile'];
      _profileController.text = employee['user Profile'];
      _emailController.text = employee['email'];
      _imageUrl = employee['imageUrl'];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveEmployeeDetails() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        var employee = widget.employeeData.firstWhere((employee) => employee['id'] == widget.employeeId);
        employee['user Name'] = _userNameController.text;
        employee['phone'] = _phoneController.text;
        employee['user Profile'] = _addressController.text;
        employee['user Profile'] = _profileController.text;
        employee['email'] = _emailController.text;
        employee['imageUrl'] = _imageUrl;
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Employee details updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee', style: TextStyle(color: Colors.white)),
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
                            : NetworkImage(_imageUrl ?? 'https://via.placeholder.com/150')
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
                  controller: _phoneController,
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
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _saveEmployeeDetails,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.userPrimaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(MediaQuery.sizeOf(context).width * 9.40, 40)),
                  child: Text(
                    'Save',
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
}
