import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_sheet/color/AppColors.dart';

class UserPanelAssignedTask extends StatelessWidget {
  final String userEmail;

  UserPanelAssignedTask({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1D1F4),
      appBar: AppBar(
        title: Text('All Tasks Assigned', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('task')
            .doc(userEmail)
            .collection('TotalTasks')
            .orderBy('taskAssignTime', descending: true)  // Order by 'taskAssignTime' in descending order
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // If there's no data, show a message
          if (snapshot.data!.docs.isEmpty) {
            print("===============$userEmail");
            return Center(child: Text('No tasks found.'));

          }
          // Otherwise, build the ListView
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Get data from Firestore document
              var document = snapshot.data!.docs[index];
              var data = document.data() as Map<String, dynamic>;

              // Check and format 'task' field
              var task = data["task"] ?? "No task name"; // Provide a default value if 'task' is null

              // Format date and time using intl package
              var dateFormat = DateFormat.yMMMMd(); // Date format
              var timeFormat = DateFormat.Hm(); // Time format

              // Parse and format taskAssignTime
              Timestamp? assignTimestamp = data['taskAssignTime'];
              String formattedAssignTime = assignTimestamp != null ? '${dateFormat.format(assignTimestamp.toDate())} at ${timeFormat.format(assignTimestamp.toDate())}' : "No assigned time"; // Handle null for 'taskAssignTime'

              // Parse and format endTime
              Timestamp? endTimestamp = data['endTime'];
              String formattedEndTime = endTimestamp != null
                  ? '${dateFormat.format(endTimestamp.toDate())} at ${timeFormat.format(endTimestamp.toDate())}'
                  : "No deadline"; // Handle null for 'endTime'

              return Card(
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey,width: 1), borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Task No: ${index + 1}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Email: ${data['user Id'] ?? "No email"}', style: TextStyle(color: Colors.black),),
                      Text('Project Name: ${data['projectName'] ?? 'No project name'}', style: TextStyle(color: Colors.black)), // Handle null for 'projectName'
                      Text('Client Name: ${data['clientName'] ?? 'No client name'}', style: TextStyle(color: Colors.black)),
                      Row(
                        children: [
                          Text('Assigned Time: ', style: TextStyle(color: Colors.black)),
                          Text('$formattedAssignTime', style: TextStyle(color: Colors.green),),
                        ],
                      ),// Handle null for 'projectName'

                      Row(
                        children: [
                          Text('Deadline:', style: TextStyle(color: Colors.black)),
                          Text(' $formattedEndTime', style: TextStyle(color: Colors.red),),
                        ],
                      )

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}