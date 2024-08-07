import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_sheet/HrDashboard/updateProjectForm.dart';
import 'package:time_sheet/color/AppColors.dart';
import '../../massage/MassageHandler.dart';

class LeaveStatus extends StatefulWidget {
  final String userEmail;
  LeaveStatus({required this.userEmail});
  @override
  _LeaveStatusState createState() => _LeaveStatusState();
}

class _LeaveStatusState extends State<LeaveStatus> {
  late List<dynamic> _projectsData = [];
  late Map<String, dynamic> ApiData;

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  Future<void> fetchEmployeeData() async {
    try {
      var response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/leaverequests/email/${widget.userEmail}')); // Replace with your actual API endpoint
      var jsonResponse = json.decode(response.body);
      ApiData = jsonResponse;
      if (jsonResponse['status'] == 1) {
        setState(() {
          _projectsData = jsonResponse['data'];
          MessageHandler.showCustomMessage(jsonResponse['message'], backgroundColor: Colors.green,);
        });
      } else {
        MessageHandler.showCustomMessage(jsonResponse['message'], backgroundColor: Colors.red,);
      }
    } catch (e) {
      MessageHandler.showCustomMessage('something went wrong $e', backgroundColor: Colors.red,);
    }
  }


  Future<void> deleteData(int id) async {
    var response = await http.delete(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/leaverequests/$id'));
    var jsonResponse = json.decode(response.body);
    Fluttertoast.showToast(msg: jsonResponse['message']);
  }


  void _deleteProject(int projectId) {
    setState(()   {
      deleteData(projectId);
      _projectsData.removeWhere((data) => data['id'] == projectId);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: AppColors.userPrimaryColor,
        title: Text('Leave Status',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _projectsData.length,
        itemBuilder: (context, index) {
          var projects = _projectsData[index];

          return Card(
            margin: EdgeInsets.all(10.0),
            elevation: 3.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.grey)
            ),
            child: ListTile(
              title: Text(' ${projects['status'] ?? 'Pending'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Reason:      ',      style: TextStyle(fontWeight: FontWeight.w600),),
                      Text(' ${projects['reason'] ?? 'No reason'}'),
                    ],
                  ),
                  SizedBox(height: 4,),
                  Row(
                    children: [
                      Text('Start_date: ',style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${projects['start_date'] ?? 'No start_date'}', style: TextStyle(color: Colors.green),),
                    ],
                  ),
                  SizedBox(height: 4,),
                  Row(
                    children: [
                      Text('End_date: ',style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${projects['end_date'] ?? 'No end_date'}', style: TextStyle(color: Colors.red),),
                    ],
                  ),
                  SizedBox(height: 4,),
                  Row(
                    children: [
                      Flexible(child: Text('total_days: ',style: TextStyle(fontWeight: FontWeight.w600))),
                      Flexible(
                        child: Text('${projects['total_days'] ?? 'No total_days'}',
                          overflow: TextOverflow.visible,),
                        fit: FlexFit.loose,
                        flex: 2,),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


