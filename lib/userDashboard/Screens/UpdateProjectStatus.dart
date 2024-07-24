import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_sheet/color/AppColors.dart';

class UpdateProjectStatus extends StatefulWidget {
  final String userEmail;

  const UpdateProjectStatus({Key? key, required this.userEmail}) : super(key: key);

  @override
  _UpdateProjectStatus createState() => _UpdateProjectStatus(userEmail);
}

class _UpdateProjectStatus extends State<UpdateProjectStatus> {
  final String userEmail;
  _UpdateProjectStatus(this.userEmail);
  final _formKey = GlobalKey<FormState>();
  String? _selectedClient;
  String? _selectedCategory;
  String? _selectedProject;
  String? _githubUrl;
  String? _selectedStatus;

  List<String> _clients = [];
  List<String> _projects = []; // Example client names
  final List<String> _categories = ['Build Structure', 'Making UI', 'Build Logics', 'Connect to Database', 'Testing', 'Deployment']; // Example categories
  final List<String> _statuses = ['Pending', 'In Progress', 'Blocked', 'Under Review', 'Completed', 'Cancelled', 'On Hold'];

  CollectionReference taskStatus = FirebaseFirestore.instance.collection("TaskStatus");


  @override
  void initState() {
    super.initState();
    _fetchProjects();
    _fetchClients();
  }


  Future<void> _fetchProjects() async {
    try {
      // Query all documents under the 'totalWork' subcollection
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('task')
          .doc(widget.userEmail)
          .collection('TotalTasks')
          .get();

      // Process each document in the query snapshot
      List<String> projects = [];
      querySnapshot.docs.forEach((doc) {
        if (doc.exists) {
          projects.add(doc['projectName'] as String);
        }
      });

      setState(() {
        _projects = projects;
      });

    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  Future<void> _fetchClients() async {
    try {
      // Query all documents under the 'totalWork' subcollection
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('task')
          .doc(widget.userEmail)
          .collection('TotalTasks')
          .get();

      // Process each document in the query snapshot
      List<String> clients = [];
      querySnapshot.docs.forEach((doc) {
        if (doc.exists) {
          clients.add(doc['clientName'] as String);
        }
      });

      setState(() {
        _clients = clients;
      });

    } catch (e) {
      print('Error fetching projects: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Update Project Status',style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Outer padding
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Project Name Dropdown
                _buildDropdownField(
                  label: 'Project Name',
                  value: _selectedProject,
                  items: _projects,
                  onChanged: (value) {
                    setState(() {
                      _selectedProject = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                // Client Name Dropdown
                _buildDropdownField(
                  label: 'Client Name',
                  value: _selectedClient,
                  items: _clients,
                  onChanged: (value) {
                    setState(() {
                      _selectedClient = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                // Category Dropdown
                _buildDropdownField(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                // GitHub URL Text Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'GitHub URL',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _githubUrl = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                // Project Status Radio Buttons
                _buildStatusRadioButtons(),
                SizedBox(height: 20),
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _selectedStatus != null) {

                      DocumentReference docsIdRef = taskStatus.doc(userEmail);
                      // Form is valid, do something with the form data
                      docsIdRef.set({
                        'userEmail': widget.userEmail,
                        'selectedProject': _selectedProject,
                        'selectedClient': _selectedClient,
                        'selectedCategory': _selectedCategory,
                        'githubUrl': _githubUrl,
                        'selectedStatus': _selectedStatus,
                        'timestamp': FieldValue.serverTimestamp(),
                      }).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Form Submitted Successfully!')),
                        );
                        // Clear form fields after submission
                        _formKey.currentState!.reset();
                        setState(() {
                          _selectedClient = null;
                          _selectedCategory = null;
                          _selectedProject = null;
                          _githubUrl = null;
                          _selectedStatus = null;
                        });
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit form: $error')),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a project status and enter a GitHub URL.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.userPrimaryButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text(
                    'Submit Status',
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(label),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }

  Widget _buildStatusRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _statuses.map((status) {
        return Row(
          children: [
            Radio<String>(
              value: status,
              mouseCursor: SystemMouseCursors.noDrop,
              activeColor: AppColors.userPrimaryButtonColor,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            Text(status),
          ],
        );
      }).toList(),
    );
  }
}