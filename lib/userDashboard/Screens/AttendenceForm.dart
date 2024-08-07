import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_sheet/color/AppColors.dart';


class AttendanceForm extends StatefulWidget {

  final String userEmail;
  final String profile;
  final String name;
  AttendanceForm({required this.userEmail, required this.profile, required this.name});
  @override
  _AttendanceFormState createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, String> _attendanceData = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    // Example API endpoint for fetching attendance data
    final url = Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/attendences/email/${widget.userEmail}');

    try {
      final response = await http.get(url);
      print(response.statusCode);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> attendanceList = data['data'];

        setState(() {
          _attendanceData.clear();
          for (var attendance in attendanceList) {
            DateTime date = DateTime.parse(attendance['created_at']);
            DateTime formattedDate = DateTime(date.year, date.month, date.day);
            _attendanceData[formattedDate] = attendance['attendence'];
            print("======$_attendanceData");
            print("--------${_attendanceData[formattedDate]}");
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _markAttendance(String status) async {
    final currentDate = DateTime.now();
    final formattedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    if (_attendanceData.containsKey(formattedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance for today is already marked')),
      );
      return;
    }

    // Check if today is Sunday
    final isSunday = currentDate.weekday == DateTime.sunday;
    final finalStatus = isSunday ? 'Sunday' : status;

    final url = Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/attendences');

    final data = {
      'email': widget.userEmail,
      'name': widget.name,
      'profile': widget.profile,
      'attendence': finalStatus,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked as $finalStatus')),
        );
        _fetchAttendanceData(); // Refresh the attendance data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark attendance')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay; // update `_focusedDay` here as well
        });
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          DateTime formattedDate = DateTime(date.year, date.month, date.day);
          if (_attendanceData[formattedDate] == 'present') {
            return _buildMarker(date.weekday == DateTime.sunday ? Colors.grey : Colors.green);
          } else if (_attendanceData[formattedDate] == 'absent') {
            return _buildMarker(date.weekday == DateTime.sunday ? Colors.grey : Colors.red);
          } else if (_attendanceData[formattedDate] == 'Sunday') {
            return _buildMarker(Colors.grey);
          }
          return null;
        },
      ),
    );
  }


  Widget _buildMarker(Color color) {
    return Positioned(
      right: 1,
      bottom: 1,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Attendance Form'),
        backgroundColor: AppColors.userPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _markAttendance('present'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  ),
                  child: Text('Present'),
                ),
                ElevatedButton(
                  onPressed: () => _markAttendance('absent'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  ),
                  child: Text('Absent'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _buildCalendar(),
            ),
          ],
        ),
      ),
    );
  }
}
