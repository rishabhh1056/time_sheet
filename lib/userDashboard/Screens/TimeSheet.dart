import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/animation.dart';
import 'package:time_sheet/color/AppColors.dart';
import '../../massage/MassageHandler.dart';

class TimeSheetForm extends StatefulWidget {
  final String userEmail;

  TimeSheetForm({required this.userEmail});

  @override
  _TimeSheetFormState createState() => _TimeSheetFormState();
}

class _TimeSheetFormState extends State<TimeSheetForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClient;
  String? _selectedCategory;
  String? _selectedProject;
  String? _selectedEt;
  String? _checkAnimation;

  DateTime? _startTime;
  DateTime? _endTime;
  double _totalHours = 0;

  bool _isRunning = false;
  late Stopwatch _stopwatch;
  late Timer _timer;

  List<String> _clients = [];
  List<String> _projects = [];
  final List<String> _categories = ['build structure', 'making Ui', 'Build Logics', 'connect to Database', 'Testing', 'Deployment'];
  final List<String> _Et = ['1hr', '2hrs', '3hrs', '4hrs', '5hrs', '6hrs', '7hrs', '8hrs', 'more than 8hrs'];

  late AnimationController _animationController;
  late Animation<double> _animation;
  final prefs =  SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _loadStopwatchState();
    _fetchProjects();
    _fetchClients();



    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRunning) {
        setState(() {});
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 24), // Set a long duration to cover possible working hours
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _timer.cancel();
    _saveStopwatchState();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString('startTime');
    if (startTimeString != null) {
      _startTime = DateTime.parse(startTimeString);
      _stopwatch..reset()..start();
      _isRunning = true;
    }
  }

  Future<void> _saveStopwatchState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isRunning) {
      final elapsedMillis = _stopwatch.elapsed.inMilliseconds;
      prefs.setString('startTime', _startTime?.toIso8601String() ?? '');
      prefs.setInt('elapsedMillis', elapsedMillis);
    } else {
      prefs.remove('startTime');
      prefs.remove('elapsedMillis');
    }
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

  Future<void> _startTimeButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      if (!_isRunning) {
        setState(() async {
          _startTime = DateTime.now();
          _stopwatch
            ..reset()
            ..start();
          _isRunning = true;
          _animationController.forward(from: 0);

          await FirebaseFirestore.instance.collection('userTimeSheet').doc(
              "Date:${DateTime(_startTime!.year, _startTime!.month, _startTime!.day)} ${widget.userEmail}").set({
            'project name': _selectedProject,
            'client name': _selectedClient,
            'category': _selectedCategory,
            'startTime': _startTime,
          });
        });

        _saveStopwatchState();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Time already started!')),
        );
      }
    } else {
      MessageHandler.fillAllDetails();
    }
  }

  Future<void> _endTimeButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      if (_isRunning) {
        setState(() async {
          _stopwatch..stop()..reset();
          _endTime = DateTime.now();
          _totalHours = _stopwatch.elapsed.inMinutes / 60.0;

          _isRunning = false;
          _animationController.stop();

          await FirebaseFirestore.instance.collection('userTimeSheet').doc(
              "Date:${DateTime(_endTime!.year, _endTime!.month, _endTime!.day)} ${widget.userEmail}").update({
            'project name': _selectedProject,
            'client name': _selectedClient,
            'category': _selectedCategory,
            'endTime': _endTime,
            'total working hours': _totalHours
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('End Time Recorded!')),
        );

        _saveStopwatchState();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Start time before ending!')),
        );
      }
    } else {
      MessageHandler.fillAllDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Time Sheet Form', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
              _buildDropdownField(
                label: 'Estimated time',
                value: _selectedEt,
                items: _Et,
                onChanged: (value) {
                  setState(() {
                    _selectedEt = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ElevatedButton(
                        onPressed: _startTimeButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          'Start Time',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ElevatedButton(
                        onPressed: _endTimeButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'End Time',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Center(
              //   child: Stack(
              //     alignment: Alignment.center,
              //     children: [
              //       CircularProgressIndicator(
              //         value: _animation.value,
              //         strokeWidth: 10.0,
              //         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              //         backgroundColor: Colors.grey[200],
              //       ),
              //       Text(
              //         _formatDuration(_stopwatch.elapsed),
              //         style: TextStyle(
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),


              SizedBox(height: 20),
              // Text(
              //   'Total Work Hours: ${_totalHours.toStringAsFixed(2)} hours',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
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
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      items: items.isNotEmpty
          ? items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList()
          : [],
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }

  Widget buildLottieAnimation({
    required String animationPath,
    double? height,
    double? width,
  }) {
    return Center(
      child: Lottie.asset(
        animationPath,
        height: height,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${duration.inHours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
