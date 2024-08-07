import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'package:time_sheet/userDashboard/Screens/AttendenceForm.dart';
import '../massage/MassageHandler.dart';
import 'Screens/AssignedTask.dart';
import 'Screens/LeaveRequest.dart';
import 'Screens/LeaveStatus.dart';
import 'Screens/TimeSheet.dart';
import 'package:http/http.dart' as http;
import 'Screens/UpdateProjectStatus.dart';

class EmployeeDashboard extends StatefulWidget {
  final String userEmail;

  EmployeeDashboard({required this.userEmail});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  late String userEmail;
  late List<dynamic> _projectsData;
   late final String? name;
   late final String? profile;

  Map<DateTime, String> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    _fetchEmployeeDetail();
    _fetchAttendanceData();// Call method in initState to fetch employee details
  }

  Future<void> _fetchEmployeeDetail() async {
    try {
      var response = await http.get(Uri.parse(
          'https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/users/email/$userEmail'));
      var jsonResponse = json.decode(response.body);

      print(response.statusCode);
      if (jsonResponse['status'] == 1) {
        setState(() {
          _projectsData = jsonResponse['data'];
          name = _projectsData[0]['name'];
          profile = _projectsData[0]['profile'];

          _markAttendance('present');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text(
          'Hello, ${extractUsername(userEmail)}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change your color here
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              if (prefs.getString('startTime') != null) {
                showLogoutAlert(context);
              } else {
                prefs.clear();
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.logout),
          )
        ],
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the cards to the full width
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 0),
              children: [
                _buildCard(
                    AssetImage('assets/images/task.png'),
                    'Assigned Task',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UserPanelAssignedTask(userEmail: userEmail,)));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/timesheetUser.png'),
                    'Time Sheet',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> TimeSheetForm(userEmail: userEmail)));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/leaveReq.png'),
                    'Leave Request',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaveRequestPage(userEmail: userEmail,)));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/status.png'),
                    'Leave Status',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaveStatus(userEmail: userEmail,)));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/attendence.png'),
                    'Attendance',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AttendanceForm(userEmail: userEmail, name: name??'', profile: profile??'',)));
                    }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      ImageProvider<Object> image,
      String text,
      Color bgColor,
      VoidCallback onPressed, // Function parameter for onPressed
      ) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: GestureDetector(
        onTap: onPressed, // Trigger onPressed function when tapped
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLogoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout? \nIf you logout, your time will also be cleared.'),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                // Clear time sheet logic would go here
                final prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pop(context);
                Navigator.of(context).pop(); // Close the alert dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Time sheet cleared successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Perform logout action or navigate to logout page
                // Replace with your actual logout logic or route
                // Example:
                // Navigator.pushReplacementNamed(context, '/logout');
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout canceled. Time sheet not cleared.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Optionally, you can handle 'No' button action here
              },
            ),
          ],
        );
      },
    );
  }

  String extractUsername(String email) {
    int atIndex = email.indexOf('@');
    String username = email.substring(0, atIndex);
    if (username.isNotEmpty) {
      username = username[0].toUpperCase() + username.substring(1);
    }
    return username;
  }


  Future<void> _markAttendance(String status) async {
    final currentDate = DateTime.now();
    final formattedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    if (_attendanceData.containsKey(formattedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance for today is already marked')),
      );
      return;
    }

    // Check if today is Sunday
    final isSunday = currentDate.weekday == DateTime.sunday;
    final finalStatus = isSunday ? 'Sunday' : status;

    final url = Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/attendences');

    final data = {
      'email': widget.userEmail,
      'name': name??'',
      'profile': profile??'',
      'attendence': finalStatus,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked as $finalStatus')),
        );
         // Refresh the attendance data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark attendance')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  Future<void> _fetchAttendanceData() async {
    // Example API endpoint for fetching attendance data
    final url = Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/attendences/email/${widget.userEmail}');

    try {
      final response = await http.get(url);
      print(response.statusCode);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> attendanceList = data['data'];

        setState(() {
          _attendanceData.clear();
          for (var attendance in attendanceList) {
            DateTime date = DateTime.parse(attendance['created_at']);
            DateTime formattedDate = DateTime(date.year, date.month, date.day);
            _attendanceData[formattedDate] = attendance['attendence'];
            print("======$_attendanceData");
            print("--------${_attendanceData[formattedDate]}");
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}
