import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../color/AppColors.dart';

class AssignedTask extends StatelessWidget {
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/tasks'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<dynamic> tasks = List.from(jsonResponse['data'].reversed);
        return tasks.map((task) => Task.fromJson(task)).toList();
      } else {
        throw Exception('Failed to load tasks: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('All Tasks Assigned', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.userPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Task>>(
        future: fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final task = snapshot.data![index];

              // Format date and time using intl package
              var dateFormat = DateFormat.yMMMMd(); // Date format
              var timeFormat = DateFormat.Hm(); // Time format

              // Format assignTime
              String formattedAssignTime = task.assignTime != null
                  ? '${dateFormat.format(task.assignTime!)} at ${timeFormat.format(task.assignTime!)}'
                  : "No assigned time";

              // Format deadline
              String formattedDeadline = task.deadline != null
                  ? '${dateFormat.format(task.deadline!)} at ${timeFormat.format(task.deadline!)}'
                  : "No deadline";

              return Card(
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blueGrey, width: 1)),
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Task No: ${index + 1}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Email: ${task.userId ?? "No email"}', style: TextStyle(color: Colors.black, fontSize: 15)),
                      Text('Description: ${task.projectName ?? 'No project name'}', style: TextStyle(color: Colors.black, fontSize: 15)),
                      Text('Client Name: ${task.clientName ?? 'No client name'}', style: TextStyle(color: Colors.black, fontSize: 15)),
                      Text('Assigned Time: $formattedAssignTime', style: TextStyle(color: Colors.black, fontSize: 15)),
                      Text('Deadline: $formattedDeadline', style: TextStyle(color: Colors.black, fontSize: 15)),
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


class Task {
  final String? id;
  final String? userId;
  final String? projectName;
  final String? clientName;
  final DateTime? assignTime;
  final DateTime? deadline;
  final String? projectDescription;

  Task({
    this.id,
    this.userId,
    this.projectName,
    this.clientName,
    this.assignTime,
    this.deadline,
    this.projectDescription,
  });

  // Factory constructor to create a Task object from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      userId: json['userId'],
      projectName: json['project_name'],
      clientName: json['client_name'],
      assignTime: json['assign_time'] != null
          ? DateTime.parse(json['assign_time'])
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      projectDescription: json['project_des'],
    );
  }
}
