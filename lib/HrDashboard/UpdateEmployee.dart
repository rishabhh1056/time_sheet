import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_sheet/HrDashboard/AddEmployees.dart';
import 'package:time_sheet/HrDashboard/UpddateEmployeeForm.dart';
import 'package:time_sheet/color/AppColors.dart';

class EmployeePage extends StatefulWidget {
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late List<dynamic> _employeeData = [];
  late Map<String, dynamic> ApiData;

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  Future<void> fetchEmployeeData() async {
    try {
      var response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/users/get/0')); // Replace with your actual API endpoint
      var jsonResponse = json.decode(response.body);
      ApiData = jsonResponse;
      if (jsonResponse['status'] == 1) {
        setState(() {
          _employeeData = jsonResponse['data'];
        });
      } else {
        print('Error: ${jsonResponse['message']}');
      }

      print(_employeeData);
    } catch (e) {
      print('Error fetching employee data: $e');
    }
  }

  Future<void> deleteEmployeeDetails(int id) async{
    var response = await http.delete(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/user/delete/$id'));
    var jsonResponse = json.decode(response.body);
    Fluttertoast.showToast(msg: jsonResponse['message']);
  }


  void _deleteEmployee(int employeeId) {
    setState(() {
      deleteEmployeeDetails(employeeId);
      _employeeData.removeWhere((data) => data['id'] == employeeId);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: AppColors.userPrimaryColor,
        title: Text('Employee Details', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _employeeData.length,
        itemBuilder: (context, index) {
          var employee = _employeeData[index];
          var imageUrl = employee['imageUrl'] ?? 'https://cdn-icons-png.flaticon.com/512/149/149071.png';

          return Card(
            margin: EdgeInsets.all(10.0),
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage('https://k61.644.mywebsitetransfer.com/timesheet-images/$imageUrl'),
              ),
              title: Text(employee['name'] ?? 'No Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Email: ', style: TextStyle(fontSize: 15, color: Colors.black),),
                      Flexible(
                          child: Text('${employee['email'] ?? 'No Email'}',style: TextStyle( color: Colors.black))
                         ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Contact: ',style: TextStyle(fontSize: 15, color: Colors.black)),
                      Text('${employee['contact'] ?? 'No Contact'}',style: TextStyle( color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Address: ',style: TextStyle(fontSize: 15, color: Colors.black)),
                      Flexible(child: Text('${employee['address'] ?? 'No Address'}',style: TextStyle( color: Colors.black))),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Profile: ',style: TextStyle(fontSize: 15, color: Colors.black)),
                      Text('${employee['profile'] ?? 'No Profile'}',style: TextStyle( color: Colors.black)),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateEmployeeForm(projectId: employee['id']),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteEmployee(employee['id']);
                      print(employee['id']);
                    },
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





