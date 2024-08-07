import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_sheet/HrDashboard/AddNewProject.dart';
import 'package:time_sheet/HrDashboard/updateProjectForm.dart';
import 'package:time_sheet/color/AppColors.dart';

import '../massage/MassageHandler.dart';

class UpdateNewProjects extends StatefulWidget {
  @override
  _UpdateNewProjectsState createState() => _UpdateNewProjectsState();
}

class _UpdateNewProjectsState extends State<UpdateNewProjects> {
  late List<dynamic> _projectsData = [];
  late Map<String, dynamic> ApiData;

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  Future<void> fetchEmployeeData() async {
    try {
      var response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details')); // Replace with your actual API endpoint
      var jsonResponse = json.decode(response.body);
      ApiData = jsonResponse;
      if (jsonResponse['status'] == 'success') {
        setState(() {
          _projectsData = List.from(jsonResponse['data'].reversed);
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
    var response = await http.delete(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details/delete/$id'));
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
        title: Text('Projects Details',style: TextStyle(color: Colors.white),),
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
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateNewProject(id: projects['id'],),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteProject(projects['id']);
                    },
                  ),
                ],
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('project name:     ',     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                      Text(' ${projects['project_name'] ?? 'No project_name'}'),
                    ],
                  ),
                  SizedBox(height: 4,),
                  Row(
                    children: [
                      const Text('client_name:      ',      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                      Text(' ${projects['client_name'] ?? 'No client_name'}'),
                    ],
                  ),

                  SizedBox(height: 4,),
                  Row(
                    children: [
                      Flexible(child: Text('budget:    ',style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                      Flexible(
                        child: Text('${projects['budget'] ?? 'No project_des'}',
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









class UpdateNewProject extends StatefulWidget {
  final int id;
  UpdateNewProject({required this.id});
  @override
  _UpdateNewProjectState createState() => _UpdateNewProjectState();
}

class _UpdateNewProjectState extends State<UpdateNewProject> {
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _clientController = TextEditingController();
  final _budgetController = TextEditingController();
  late Map<String, dynamic> _projectsData;

  @override
  void initState() {
    fetchProjectData();
    super.initState();
  }

  Future<void> fetchProjectData() async {
    try {
      var response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details/${widget.id}')); // Replace with your actual API endpoint
      var jsonResponse = json.decode(response.body);
      print(response.statusCode);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          _projectsData = jsonResponse['data'];

          _projectController.text = _projectsData['project_name'] ?? '';
          _clientController.text = _projectsData['client_name'] ?? '';
          _budgetController.text = _projectsData['budget'] ?? '';
          MessageHandler.showCustomMessage(jsonResponse['message'], backgroundColor: Colors.green,);
        });
      } else {
        MessageHandler.showCustomMessage(jsonResponse['message'], backgroundColor: Colors.red,);
      }
      print(_projectsData);
    } catch (e) {
      MessageHandler.showCustomMessage('something went wrong $e', backgroundColor: Colors.red,);
      print(e);
    }
  }



  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.put(
          Uri.parse(
              'https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details/update/${widget.id}'),
          body: {
            'project_name': _projectController.text,
            'client_name': _clientController.text,
            'budget': _budgetController.text,
          },
        );
        var jsonResponse = json.decode(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      }
      catch(e){
        print('something went wrong $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Project Form', style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          padding: const EdgeInsets.all(30.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _projectController,
                  decoration: InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter project name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _clientController,
                  decoration: InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter client name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _budgetController,
                  decoration: InputDecoration(
                    labelText: 'Budget',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter budget';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      // fixedSize: ,
                      backgroundColor: AppColors.userPrimaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Submit', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
