import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:time_sheet/color/AppColors.dart';

import '../../massage/MassageHandler.dart';



class TaskAssignmentForm extends StatefulWidget {
  @override
  _TaskAssignmentFormState createState() => _TaskAssignmentFormState();
}

class _TaskAssignmentFormState extends State<TaskAssignmentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _projectNameController = TextEditingController();
  TextEditingController _ClientNameController = TextEditingController();
  DateTime? _taskAssignTime;
  DateTime? _endTime;
  String? _selectedUserId;

  MessageHandler massage = MessageHandler();

  var dateFormat = DateFormat.yMMMMd(); // Date format
  var timeFormat = DateFormat.Hm(); // Time format

  CollectionReference task = FirebaseFirestore.instance.collection("task");
  CollectionReference TotalAssignedTask = FirebaseFirestore.instance.collection("tasks");
  CollectionReference users = FirebaseFirestore.instance.collection("EmployeeDetails");

  @override
  void initState() {
    super.initState();
    // Fetch user IDs for dropdown when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Task Assignment',style: TextStyle(color: Colors.white)),
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
                  StreamBuilder<QuerySnapshot>(
                    stream: users.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
        
                      List<DropdownMenuItem<String>> userDropdownItems = snapshot.data!.docs.map((doc) {
                        String userId = doc.id; // Assuming the document ID is the user ID
                        return DropdownMenuItem<String>(
                          value: userId,
                          child: Text(userId),
                        );
                      }).toList();
        
                      return DropdownButtonFormField<String>(
                        value: _selectedUserId,
                        items: userDropdownItems,
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'User ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a user ID';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _projectNameController,
                    labelText: 'Project Name',
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _ClientNameController,
                    labelText: 'Client Name',
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
                    labelText: 'End Time',
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.userPrimaryButtonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),minimumSize: Size(MediaQuery.sizeOf(context).width *9.40, 40)),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {

      String emaiId = _selectedUserId.toString();
      print("_________________ $emaiId================================");

      // Reference to the 'users' collection
      DocumentReference userDocRef = task.doc(emaiId);

      // Add task details to the 'tasks' subcollection within the user's document
      userDocRef.collection('TotalTasks').add({
        'user Id': _selectedUserId,
        'projectName': _projectNameController.text,
        'clientName': _ClientNameController.text,
        'taskAssignTime': _taskAssignTime,
        'endTime': _endTime,
      }).then((value) {
        // Show a toast message and clear form on successful upload

        MessageHandler.taskAssigned();

        _projectNameController.clear();
        _ClientNameController.clear();
        setState(() {
          _taskAssignTime = null;
          _endTime = null;
          _selectedUserId = null; // Clear the selected user ID
        });
      }).catchError((error) {
        // Handle errors here
        MessageHandler.taskAssignedFailed();
      });


      TotalAssignedTask.add({
        "Employee Email": _selectedUserId,
        'projectName': _projectNameController.text,
        'clientName': _ClientNameController.text,
        'taskAssignTime': _taskAssignTime,
        'endTime': _endTime,
      }).then((value) {
        // Show a toast message and clear form on successful upload

        _projectNameController.clear();
        _ClientNameController.clear();
        setState(() {
          _taskAssignTime = null;
          _endTime = null;
          _selectedUserId = null; // Clear the selected user ID
        });
      }).catchError((error) {
        // Handle errors here

      });
    } else {
      // If validation fails, show an error message
      MessageHandler.fillAllDetails();
    }
  }
}
