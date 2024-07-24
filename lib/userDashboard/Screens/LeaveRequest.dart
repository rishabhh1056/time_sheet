import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_sheet/color/AppColors.dart';

import '../../massage/MassageHandler.dart';

class RequestLeavePage extends StatefulWidget {
  @override
  _RequestLeavePageState createState() => _RequestLeavePageState();
}

class _RequestLeavePageState extends State<RequestLeavePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _profileController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String _reason = 'Sick Leave';

  final List<String> _reasons = ['Sick Leave', 'Personal Leave', 'Vacation'];

  CollectionReference LeaveRequest = FirebaseFirestore.instance.collection(
      "requestLeave");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: AppColors.userPrimaryColor,
        title: Text('Request Leave', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _profileController,
                  decoration: InputDecoration(
                    labelText: 'Profile',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your profile';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  value: _reason,
                  items: _reasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _reason = value!;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickStartDate,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickEndDate,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.userPrimaryButtonColor,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: _submitForm,
                  child: Text('Submit', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _startDateController.text =
        pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _endDateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Perform form submission logic here, such as sending data to a server
      print('First Name: ${_firstNameController.text}');
      print('Profile: ${_profileController.text}');
      print('Reason: $_reason');
      print('Start Date: ${_startDateController.text}');
      print('End Date: ${_endDateController.text}');

      LeaveRequest.add({
        'Name': _firstNameController.text,
        'Profile': _profileController.text,
        'Reason': _reason,
        'Start Date': _startDateController.text,
        'End Date': _endDateController.text
      }).then((value) {
        MessageHandler.showCustomMessage(
            "Submit Leave Request", backgroundColor: Colors.green);
        _firstNameController.clear();
        _profileController.clear();
        _startDateController.clear();
        _endDateController.clear();
      }).catchError((error) {
        MessageHandler.showCustomMessage(
            "Failed Leave Request", backgroundColor: Colors.red);
      });
    }
  }
}
