import 'package:flutter/material.dart';
import 'package:time_sheet/color/AppColors.dart';

class AddProjectPage extends StatefulWidget {
  @override
  _AddProjectPageState createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _projectNameController = TextEditingController();
  TextEditingController _clientNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _assignTimeController = TextEditingController();
  TextEditingController _deadlineController = TextEditingController();

  DateTime? _taskAssignTime;
  DateTime? _taskDeadLineTime;

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
                    _submitForm();
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
  }) {
    return TextFormField(
      controller: controller,
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
            fillColor: Colors.white,
            filled: true,
            labelText: labelText,
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


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, handle the submission
      String projectName = _projectNameController.text;
      String clientName = _clientNameController.text;
      String description = _descriptionController.text;
      String assignedTime = _assignTimeController.text;
      String deadline = _deadlineController.text;

      // Handle project addition logic here
      // For example, print values to the console
      print('Project Name: $projectName');
      print('Client Name: $clientName');
      print('Description: $description');
      print('Assigned Time: $assignedTime');
      print('Deadline: $deadline');

      // Show success message or navigate to another page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project Added Successfully')),
      );

      // Clear the form
      _projectNameController.clear();
      _clientNameController.clear();
      _descriptionController.clear();
      _assignTimeController.clear();
      _deadlineController.clear();
    }
  }
}
