import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'package:http/http.dart' as http;

class AddProjectPage extends StatefulWidget {
  @override
  _AddProjectPageState createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _assignManagerController = TextEditingController();

  DateTime? _taskAssignTime;
  DateTime? _taskDeadLineTime;

  String? _selectedProject;
  String? _selectedClient;
  String? _selectedManager;

  List<String> projectNames = [];
  List<String> _clients = [];
  List<String> _managers = [];

  late List<dynamic> _projectData;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
    _fetchManagers();
  }

  Future<void> _fetchProjects() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details'));
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == "success") {
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

  Future<void> _fetchClients() async {
    if (_selectedProject == null) return;

    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details/project_name/$_selectedProject'));
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 1) {
        setState(() {
          _projectData = jsonResponse['data'];
          _clients = _projectData.map((project) => project['client_name'] as String).toList();
          _selectedClient = null; // Reset selected client
        });
      } else {
        throw Exception('Failed to load client names');
      }
    } catch (e) {
      print('Error fetching client names: $e');
    }
  }

  Future<void> _fetchManagers() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/users/status_code/2'));
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 1) {
        setState(() {
          List<dynamic> _projectData = jsonResponse['data'];
          _managers = _projectData.map((project) => project['email'] as String).toList();
        });
      } else {
        throw Exception('Failed to load project names');
      }
    } catch (e) {
      print('Error fetching manager names: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Add Project', style: TextStyle(color: Colors.white)),
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
                _buildDropdownField(
                  value: _selectedProject,
                  items: projectNames,
                  onChanged: (value) {
                    setState(() {
                      _selectedProject = value;
                      _fetchClients(); // Fetch clients when a project is selected
                    });
                  },
                  labelText: 'Select Project',
                ),
                SizedBox(height: 16.0),
                if (_clients.isNotEmpty) // Only show client dropdown if there are clients
                  _buildDropdownField(
                    value: _selectedClient,
                    items: _clients,
                    onChanged: (value) {
                      setState(() {
                        _selectedClient = value;
                      });
                    },
                    labelText: 'Select Client',
                  ),
                SizedBox(height: 16.0),
                _buildDropdownField(
                  value: _selectedManager,
                  items: _managers,
                  onChanged: (value) {
                    setState(() {
                      _selectedManager = value;
                    });
                  },
                  labelText: 'Assign Manager',
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _descriptionController,
                  labelText: 'Project Description',
                  maxLength: 256,
                  maxLines: 4,
                ),
                SizedBox(height: 16.0),
                _buildDateTimePicker(
                  labelText: "Assign Time",
                  selectedDate: _taskAssignTime,
                  selectDate: (DateTime date) {
                    setState(() {
                      _taskAssignTime = date;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                _buildDateTimePicker(
                  labelText: "Deadline Time",
                  selectedDate: _taskDeadLineTime,
                  selectDate: (DateTime date) {
                    setState(() {
                      _taskDeadLineTime = date;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      submitData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.userPrimaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text(
                    'Add Project',
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
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(dateText),
            SizedBox(width: 8.0),
            Text(timeText),
            Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> submitData() async {
    String description = _descriptionController.text;
    String assignManager = _assignManagerController.text;
    String assignedTime = _taskAssignTime?.toIso8601String() ?? '';
    String deadline = _taskDeadLineTime?.toIso8601String() ?? '';

    // API URL
    String url = 'https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/addproject';

    // Create the request body
    Map<String, String> requestBody = {
      'project_name': _selectedProject ?? '',
      'client_name': _selectedClient ?? '',
      'project_des': description,
      'assign_manager': _selectedManager ?? '',
      'assign_time': assignedTime,
      'deadline_time': deadline,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 201) {

        // If the server returns a 201 Created response
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('successfully add project'),
        ));
      } else {
        // If the server did not return a 201 Created response
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to add Project'),
        ));
      }
    } catch (error) {
      // Handle any errors that occur during the request
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred'),
      ));
    }
  }
}
