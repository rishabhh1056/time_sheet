import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_marquee/text_marquee.dart';
import 'package:time_sheet/HrDashboard/LeaveRequest.dart';
import 'package:time_sheet/adminDashboard/Screens/AssignedTask.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'Screens/AssignedTask.dart';
import 'Screens/LeaveRequest.dart';
import 'Screens/TimeSheet.dart';
import 'Screens/UpdateProjectStatus.dart';

class EmployeeDashboard extends StatelessWidget {
  final String userEmail;

  EmployeeDashboard({required this.userEmail});

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
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaveRequestPage()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/status.png'),
                    'Leave Status',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaveRequestsPage()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/attendence.png'),
                    'Attendance',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaveRequestsPage()));
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

}
