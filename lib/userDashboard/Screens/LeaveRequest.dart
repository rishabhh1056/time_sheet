import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:time_sheet/color/AppColors.dart';

import '../../massage/MassageHandler.dart';

class LeaveRequestPage extends StatefulWidget {
  final String userEmail;
  LeaveRequestPage({required this.userEmail});
  @override
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalDays = 0;
  late List<dynamic> _projectsData;

  @override
  void initState() {
    _fetchEmployeeDetail();
    super.initState();
  }

  Future<void> _fetchEmployeeDetail() async {
    try {
      var response = await http.get(Uri.parse(
          'https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/users/email/${widget.userEmail}'));
      var jsonResponse = json.decode(response.body);

       print(response.statusCode);
      if (jsonResponse['status'] == 1) {
        setState(() {
          _projectsData = jsonResponse['data'];
        });
      } else {
        MessageHandler.showCustomMessage(
            jsonResponse['message'], backgroundColor: Colors.red);
      }
      print(_projectsData);
    } catch (e) {
      MessageHandler.showCustomMessage(
          'Something went wrong: $e', backgroundColor: Colors.red);
    }
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        var response = await http.post(
          Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/leaverequest'), // Replace with your API URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _projectsData[0]['email'],
            'name': _projectsData[0]['name'],
            'profile': _projectsData[0]['profile'],
            'reason': _reasonController.text,
            'start_date': _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : '',
            'end_date': _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : '',
            'total_days': _totalDays,
          }),
        );

        var responseBody = jsonDecode(response.body);
         print(response.statusCode);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Leave request submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit leave request: ${responseBody['message']}')),
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

  void _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null) {
            _calculateTotalDays();
          }
        } else {
          _endDate = picked;
          if (_startDate != null) {
            _calculateTotalDays();
          }
        }
      });
    }
  }

  void _calculateTotalDays() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _totalDays = _endDate!.difference(_startDate!).inDays + 1; // +1 to include both start and end date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: AppColors.userPrimaryColor,
        title: Text('Leave Request', style: TextStyle(color: Colors.white),),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Request Leave',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the reason';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _startDate != null ? 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}' : 'Start Date',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text('Select Start Date'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _endDate != null ? 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}' : 'End Date',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text('Select End Date'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Total Days: $_totalDays',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.userPrimaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('Submit Leave Request', style: TextStyle(fontSize: 14, color: Colors.white)),
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
}
