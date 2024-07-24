import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_marquee/text_marquee.dart';
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
          _buildUpdateBoard(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Outer padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the cards to the full width
                children: [
                  // First Card
                  Card(
                    margin: EdgeInsets.only(bottom: 20), // Margin between cards
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        // Navigate to a new screen on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserPanelAssignedTask(userEmail: userEmail)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // Card inner padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Total Assign Tasks',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'View and manage all assigned tasks.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Second Card
                  Card(
                    margin: EdgeInsets.only(bottom: 20), // Margin between cards
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        // Navigate to the TimeSheetForm screen on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TimeSheetForm(userEmail: userEmail)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // Card inner padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Make Today\'s Time Sheet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Fill out the time sheet for today\'s work.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Third Card
                  Card(
                    margin: EdgeInsets.only(bottom: 20), // Margin between cards
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        // Navigate to the UpdateProjectStatus screen on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdateProjectStatus(userEmail: userEmail)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // Card inner padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Update Your Task',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Provide the status of your task.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //forth card
                  Card(
                    margin: EdgeInsets.only(bottom: 20), // Margin between cards
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        // Navigate to the UpdateProjectStatus screen on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RequestLeavePage(),));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // Card inner padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Leave Request',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'write a form to HR for leave request',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildUpdateBoard() {
    return Container(
      width: double.infinity,
      height: 30,
      color: Colors.blueAccent,
      child: TextMarquee(
        'Daily Hr updates Here *Updateds* *Updateds* *Updateds* *Updateds* *Updateds* *Updateds* *Updateds* *Updateds* *Updateds* *Updateds* *Updateds*',
        spaceSize: 72,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        duration: Duration(seconds: 12),
        delay: Duration(seconds: 1),
        rtl: true,
        startPaddingSize: 50,
      ),
    );
  }
}
