import 'dart:async';
import 'dart:convert';  // Import for JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Import for HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> projectNames = [];
  final List<String> _categories = ['build structure', 'making Ui', 'Build Logics', 'connect to Database', 'Testing', 'Deployment'];
  final List<String> _Et = ['complete', 'in-Process', 'pending', 'hold', 'not started'];

  late AnimationController _animationController;
  late Animation<double> _animation;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _loadStopwatchState();
    _fetchProjectNames();
    _fetchClientNames();

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
    prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString('startTime');
    final elapsedMillis = prefs.getInt('elapsedMillis') ?? 0;

    if (startTimeString != null) {
      _startTime = DateTime.parse(startTimeString);
      _stopwatch..reset()..start();
      _isRunning = true;
      _stopwatch.elapsed + Duration(milliseconds: elapsedMillis);
    }
  }

  Future<void> _saveStopwatchState() async {
    if (_isRunning) {
      final elapsedMillis = _stopwatch.elapsed.inMilliseconds;
      prefs.setString('startTime', _startTime?.toIso8601String() ?? '');
      prefs.setInt('elapsedMillis', elapsedMillis);
    } else {
      prefs.remove('startTime');
      prefs.remove('elapsedMillis');
    }
  }

  Future<void> _fetchProjectNames() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/tasks/email/${widget.userEmail}')); // Replace with your API endpoint
      var jsonResponse = json.decode(response.body);
      print(response.statusCode);
      if (jsonResponse['status'] == 1) {
        setState(() {
          List<dynamic> _projectData = jsonResponse['data'];
          projectNames = _projectData.map((project) => project['project_name'] as String).toList();
        });
      } else {
        throw Exception('Failed to load project names');
      }
    } catch (e) {
      print('Error fetching project names: $e');
    }
  }

  Future<void> _fetchClientNames() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/project-details/project_name/$_selectedProject')); // Replace with your API endpoint
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        print(response.statusCode);
        setState(() {
          List<dynamic> _clientData = jsonResponse['data'];
          _clients = _clientData.map((client) => client['client_name'] as String).toList();
        });
      } else {
        throw Exception('Failed to load client names');
      }
    } catch (e) {
      print('Error fetching client names: $e');
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

          final url = 'https://your-api-endpoint/start-time'; // Replace with your API endpoint
          final response = await http.post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'email': widget.userEmail,
              'project name': _selectedProject,
              'client name': _selectedClient,
              'category': _selectedCategory,
              'startTime': _startTime?.toIso8601String(),
            }),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to post start time');
          }
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

          final url = 'https://your-api-endpoint/end-time'; // Replace with your API endpoint
          final response = await http.post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'email': widget.userEmail,
              'project name': _selectedProject,
              'client name': _selectedClient,
              'category': _selectedCategory,
              'endTime': _endTime?.toIso8601String(),
              'total working hours': _totalHours,
            }),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to post end time');
          }
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
                items: projectNames,
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value;
                    _fetchClientNames();
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
                label: 'Task Name',
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
                label: 'project status',
                value: _selectedEt,
                items: _Et,
                onChanged: (value) {
                  setState(() {
                    _selectedEt = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                'Elapsed Time: ${_stopwatch.elapsed.inHours}:${_stopwatch.elapsed.inMinutes.remainder(60)}:${_stopwatch.elapsed.inSeconds.remainder(60)}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              _buildButton(
                label: 'Start Time',
                onPressed: _startTimeButtonPressed,
                color: Colors.green,
              ),
              SizedBox(height: 10),
              _buildButton(
                label: 'End Time',
                onPressed: _endTimeButtonPressed,
                color: Colors.red,
              ),
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
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
