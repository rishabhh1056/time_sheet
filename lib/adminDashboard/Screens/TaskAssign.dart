import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For json encoding/decoding

import '../../color/AppColors.dart';
import '../../massage/MassageHandler.dart';

class TaskAssignmentForm extends StatefulWidget {
  final String userEmail;
  TaskAssignmentForm({required this.userEmail});
  @override
  _TaskAssignmentFormState createState() => _TaskAssignmentFormState();
}

class _TaskAssignmentFormState extends State<TaskAssignmentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _taskAssignTime;
  DateTime? _endTime;
  String? _selectedUserId;
  String? _selectedProjectName;
  String? _selectedClientName;

  MessageHandler massage = MessageHandler();

  var dateFormat = DateFormat.yMMMMd(); // Date format
  var timeFormat = DateFormat.Hm(); // Time format
  final _desController = TextEditingController();

  List<String> userIds = []; // List of user IDs for dropdown
  List<String> projectNames = []; // List of project names for dropdown
  List<String> clientNames = []; // List of client names for dropdown

  @override
  void initState() {
    super.initState();
    _fetchUserIds();
    _fetchProjectNames();
  }

  Future<void> _fetchUserIds() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/users/status_code/1'));
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 1) {
        setState(() {
          List<dynamic> _employeeData = jsonResponse['data'];
          userIds = _employeeData.map((employee) => employee['email'] as String).toList();
        });
      } else {
        throw Exception('Failed to load user IDs');
      }
    } catch (e) {
      print('Error fetching user IDs: $e');
    }
  }

  Future<void> _fetchProjectNames() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/projects/email/${widget.userEmail}')); // Replace with your API endpoint
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 1) {
        setState(() {
          List<dynamic> _projectData = jsonResponse['data'];
          projectNames = _projectData.map((project) => project['project_name'] as String).toList();
        });
      } else {
        throw Exception('Failed to load project names');
      }
    } catch (e) {
      print('Error fetching project names: $e');
    }
  }

  Future<void> _fetchClientNames() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details/project_name/$_selectedProjectName')); // Replace with your API endpoint
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 1) {
        setState(() {
          List<dynamic> _clientData = jsonResponse['data'];
          clientNames = _clientData.map((client) => client['client_name'] as String).toList();
        });
      } else {
        throw Exception('Failed to load client names');
      }
    } catch (e) {
      print('Error fetching client names: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Task Assignment', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(vertical: 70),
            width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey),
                color: Colors.white
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Dropdown for User IDs
                  _buildDropdownField(
                    value: _selectedUserId,
                    items: userIds,
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                      });
                    },
                    labelText: 'Select Employee ID',
                  ),
                  SizedBox(height: 16.0),
                  _buildDropdownField(
                    value: _selectedProjectName,
                    items: projectNames,
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectName = value;
                        _fetchClientNames(); // Fetch clients when a project is selected
                      });
                    },
                    labelText: 'Select Project',
                  ),
                  SizedBox(height: 16.0),
                  _buildDropdownField(
                    value: _selectedClientName,
                    items: clientNames,
                    onChanged: (value) {
                      setState(() {
                        _selectedClientName = value;
                      });
                    },
                    labelText: 'Select clients',
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _desController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildDateTimePicker(
                    labelText: 'Task Assign Time',
                    selectedDate: _taskAssignTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _taskAssignTime = date;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildDateTimePicker(
                    labelText: 'Deadline',
                    selectedDate: _endTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _endTime = date;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.userPrimaryButtonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(MediaQuery.sizeOf(context).width * 0.9, 40),
                    ),
                    child: Text('Assign Task', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildDateTimePicker({
    required String labelText,
    required DateTime? selectedDate,
    required Function(DateTime) selectDate,
  }) {
    String dateText = selectedDate != null
        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
        : 'Select Date';

    String timeText = selectedDate != null
        ? '${selectedDate.hour}:${selectedDate.minute}'
        : 'Select Time';

    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
          );

          if (pickedTime != null) {
            DateTime combinedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            selectDate(combinedDateTime);
          }
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
          ),
          textAlign: TextAlign.center,
          validator: (value) {
            if (selectedDate == null) {
              return 'Please select $labelText';
            }
            return null;
          },
          controller: TextEditingController(
            text: selectedDate != null ? '$dateText $timeText' : '',
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String emailId = _selectedUserId.toString();

      final response = await http.post(
        Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/assigntasks'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': emailId,
          'project_name': _selectedProjectName,
          'client_name': _selectedClientName,
          'assign_time': _taskAssignTime?.toIso8601String(),
          'deadline': _endTime?.toIso8601String(),
          'project_des': _desController.text
        }),
      );

      if (response.statusCode == 201) {
        MessageHandler.taskAssigned();

        setState(() {
          _selectedUserId = null;
          _selectedProjectName = null;
          _selectedClientName = null;
          _taskAssignTime = null;
          _endTime = null;
          _desController.clear();
        });
      } else {
        MessageHandler.taskAssignedFailed();
      }
    } else {
      MessageHandler.fillAllDetails();
    }
  }
}

Widget _buildDropdownField({
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
  required String labelText,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList(),
    onChanged: onChanged,
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
      if (value == null) {
        return 'Please select $labelText';
      }
      return null;
    },
  );
  }