import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'package:http/http.dart' as http;

import '../massage/MassageHandler.dart';
class UpdateProjectForm extends StatefulWidget {
  final int projectId;
  UpdateProjectForm({required this.projectId});
  @override
  _UpdateProjectFormState createState() => _UpdateProjectFormState();
}

class _UpdateProjectFormState extends State<UpdateProjectForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _projectNameController = TextEditingController();
  TextEditingController _clientNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _assignManagerController = TextEditingController();
  TextEditingController _assignTimeController = TextEditingController();
  TextEditingController _deadlineController = TextEditingController();



  DateTime? _taskAssignTime;
  DateTime? _taskDeadLineTime;

  late Map<String, dynamic> _projectsData;
  late Map<String, dynamic> ApiData;

  Future<void> fetchProjectData() async {
    try {
      var response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/projects/${widget.projectId}')); // Replace with your actual API endpoint
      var jsonResponse = json.decode(response.body);
      ApiData = jsonResponse;
      if (jsonResponse['status'] == 'success') {
        setState(() {
          _projectsData = jsonResponse['data'];

          _projectNameController.text = _projectsData['project_name'] ?? '';
          _clientNameController.text = _projectsData['client_name'] ?? '';
          _descriptionController.text = _projectsData['project_des'] ?? '';
          _assignManagerController.text = _projectsData['assign_manager'] ?? '';
          _taskAssignTime = DateTime.tryParse(_projectsData['assign_time'] ?? '');
          _taskDeadLineTime = DateTime.tryParse(_projectsData['assign_time'] ?? '');
        });
      } else {
        MessageHandler.showCustomMessage(jsonResponse['message'], backgroundColor: Colors.red,);
      }
      print(_projectsData);
    } catch (e) {
      MessageHandler.showCustomMessage('something went wrong $e', backgroundColor: Colors.red,);
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProjectData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Update Project Form', style: TextStyle(color: Colors.white)),
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
                _buildTextFormField(
                  controller: _projectNameController,
                  labelText: 'Project Name',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _clientNameController,
                  labelText: 'Client Name',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                    controller: _descriptionController,
                    labelText: 'Project Description',
                    maxLength: 256,
                    maxLines: 4
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                    controller: _assignManagerController,
                    labelText: 'Assign Manager',
                    maxLength: 256,
                    maxLines: 1
                ),
                SizedBox(height: 16.0),
                _buildDateTimePicker(labelText: "Assign Time",
                    selectedDate: _taskAssignTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _taskAssignTime = date;
                      });
                    }),
                SizedBox(height: 16.0),
                _buildDateTimePicker(labelText: "DeadLine Time",
                    selectedDate: _taskDeadLineTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _taskDeadLineTime = date;
                      });
                    }),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    submitData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.userPrimaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text(
                    'Update Project',
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
    TextInputType? keyboardType,
    int maxLines = 1,
    int maxLength = 20,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        filled: true,
        counterText: '',
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
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
          ),
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

  Future<void> submitData() async {
    String projectName = _projectNameController.text;
    String clientName = _clientNameController.text;
    String description = _descriptionController.text;
    String assignManager = _assignManagerController.text;
    String assignedTime = _taskAssignTime?.toIso8601String() ?? '';
    String deadline = _taskDeadLineTime?.toIso8601String() ?? '';

    // API URL
    String url = 'https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/projects/update/${widget.projectId}';

    // Create the request body
    Map<String, String> requestBody = {
      'project_name': projectName,
      'client_name': clientName,
      'project_des': description,
      'assign_manager': assignManager,
      'assign_time': assignedTime,
      'deadline_time': deadline,
    };

    _projectNameController.clear();
    _clientNameController.clear();
    _descriptionController.clear();
    _assignManagerController.clear();
    _assignTimeController.clear();
    _deadlineController.clear();

    setState(() {
      _taskAssignTime = null;
      _taskDeadLineTime = null;
      Navigator.pop(context, true);
    });
    try {
      // Make the POST request
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response
        MessageHandler.showCustomMessage(jsonResponse['message'],backgroundColor: Colors.green);
      } else {
        // If the server did not return a 200 OK response
        MessageHandler.showCustomMessage(jsonResponse['message'],backgroundColor: Colors.red);
      }
    } catch (error) {
      // Handle any errors that occur during the request
      MessageHandler.somethingWentWrong();
    }
  }



}
