import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

import 'package:time_sheet/color/AppColors.dart';

class Attendence extends StatefulWidget {
  @override
  _AttendenceState createState() => _AttendenceState();
}

class _AttendenceState extends State<Attendence> {
  String? _selectedUserId;
  List<String> userIds = [];
  Map<DateTime, String> _attendanceData = {};
  Map<String, int> _overallAttendance = {'present': 20, 'absent': 5, 'Sunday': 4};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  int totalPresent = 0;
  int totalAbsent = 0;
  int totalSunday = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserIds();
    _fetchOverallAttendance();
  }

  Future<void> _fetchUserIds() async {
    try {
      final response = await http.get(Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/users/status_code/1'));
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 1) {
        setState(() {
          List<dynamic> _employeeData = jsonResponse['data'];
          userIds = _employeeData.map((employee) => employee['email'] as String).toList();
        });
      } else {
        throw Exception('Failed to load user IDs');
      }
    } catch (e) {
      print('Error fetching user IDs: $e');
    }
  }

  Future<void> _fetchAttendanceData() async {
    // Example API endpoint for fetching attendance data
    final url = Uri.parse('https://k61.644.mywebsitetransfer.com/timesheet-api/public/api/attendences/email/$_selectedUserId');

    try {
      print(_selectedUserId);
      final response = await http.get(url);
      print(response.statusCode);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> attendanceList = data['data'];

        setState(() {
          _attendanceData.clear();
          totalPresent = 0;
          totalAbsent = 0;
          totalSunday = 0;
          for (var attendance in attendanceList) {
            DateTime date = DateTime.parse(attendance['created_at']);
            DateTime formattedDate = DateTime(date.year, date.month, date.day);
            String status = attendance['attendence'];

            _attendanceData[formattedDate] = status;

            if(status == 'present'){
               totalPresent++;
            }
            else if(status == 'absent'){
              totalAbsent++;
            }
            else if(status == 'Sunday'){
              totalSunday++;
            }

            print("======$_attendanceData");
            print("--------${_attendanceData[formattedDate]}");
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
        setState(() {
          _attendanceData.clear();
          totalPresent = 0;
          totalAbsent = 0;
          totalSunday = 0;
        });

      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _fetchOverallAttendance() async {
    // Replace with your API URL
    final response = await http.get(
        Uri.parse('https://your-api-url/overall-attendance'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _overallAttendance = {
          'present': data['present'],
          'absent': data['absent'],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(title: Text('Attendence Report', style: TextStyle(color: Colors.white),),
      backgroundColor: AppColors.userPrimaryColor,
      iconTheme: IconThemeData(color: Colors.white),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField(
              value: _selectedUserId,
              items: userIds,
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                  _fetchAttendanceData();
                });
              },
              labelText: 'Select Employee ID',
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
            SizedBox(height: 16.0),
            buildAttendanceBarChart(totalPresent,totalAbsent,totalSunday),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String labelText,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select $labelText';
        }
        return null;
      },
    );
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

  Widget buildAttendanceBarChart(int present, int absent , int sunday) {
    // Calculate total present and absent days
    final totalPresent = present;
    final totalAbsent = absent;
    final totalSunday = sunday;

    return Container(
      height: 310,
      width: 410,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 30,
          // Adjust based on the maximum value you expect
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              )
            )
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: const Color(0xff37434d),
              width: 1,
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: totalPresent,
              barRods: [
                BarChartRodData(
                  toY: totalPresent.toDouble(),
                  color: Colors.green,
                  width: 60,
                  borderRadius: BorderRadius.circular(0),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 26,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: totalAbsent,
              barRods: [
                BarChartRodData(
                  toY: totalAbsent.toDouble(),
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(0),
                  width: 60,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 26,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: totalSunday,
              barRods: [
                BarChartRodData(
                  toY: totalSunday.toDouble(),
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(0),
                  width: 60,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 26,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
