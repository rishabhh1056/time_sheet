import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:time_sheet/color/AppColors.dart';

import '../massage/MassageHandler.dart';

class LeaveRequestsPage extends StatefulWidget {
  @override
  _LeaveRequestsPageState createState() => _LeaveRequestsPageState();
}

class _LeaveRequestsPageState extends State<LeaveRequestsPage> {
  List<dynamic> _leaveRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  Future<void> _fetchLeaveRequests() async {
    final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/leaverequests'));

    if (response.statusCode == 200) {
      setState(() {
        _leaveRequests = json.decode(response.body)['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error case
      print('Failed to load leave requests');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: AppColors.userPrimaryColor,
        title: Text('Leave Requests', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16.0),
        children: _leaveRequests.map((request) {
          return LeaveRequestCard(request: request);
        }).toList(),
      ),
    );
  }
}

class LeaveRequestCard extends StatelessWidget {
  final dynamic request;

  LeaveRequestCard({required this.request});

  final TextEditingController _customMessageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${request['name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Profile: ${request['profile']}', style: TextStyle(fontSize: 16)),
            Text('Reason: ${request['reason']}', style: TextStyle(fontSize: 16)),
            Text('Start Date: ${request['start_date']}', style: TextStyle(fontSize: 16)),
            Text('End Date: ${request['end_date']}', style: TextStyle(fontSize: 16)),
            Text('Status: ${request['status']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateRequestStatus(request['id'], 'Approved'),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _updateRequestStatus(request['id'], 'Denied'),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showCustomMessageDialog(context, request['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateRequestStatus(dynamic id, String status) async {
    final url = Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/leaverequests/${id.toString()}/status');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        // Successfully updated the request status
        MessageHandler.showCustomMessage("leave $status");
      } else {
        // Handle error case
        MessageHandler.somethingWentWrong();
      }
    } catch (e) {
      // Handle network or other errors
      MessageHandler.showCustomMessage('An error occurred: $e', backgroundColor: Colors.red);
    }
  }


  void _showCustomMessageDialog(BuildContext context, dynamic id) {
    print("Showing custom message dialog with id: $id"); // Debugging line
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Custom Message'),
          content: TextField(
            controller: _customMessageController,
            decoration: InputDecoration(labelText: 'Enter your message'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _customMessageController.clear();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final url = Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/leaverequests/${id.toString()}/status');

                try {
                  final response = await http.patch(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({'status': _customMessageController.text}),
                  );

                  if (response.statusCode == 200) {
                    // Successfully updated the request status
                    MessageHandler.showCustomMessage("leave Status updated successfully");
                  } else {
                    // Handle error case
                    MessageHandler.somethingWentWrong();
                  }
                } catch (e) {
                  // Handle network or other errors
                  MessageHandler.showCustomMessage('An error occurred: $e', backgroundColor: Colors.red);
                }

                Navigator.of(context).pop();
                _customMessageController.clear();
              },
            ),
          ],
        );
      },
    );
  }

}
