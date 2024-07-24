import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:marquee_list/marquee_list.dart';
import 'package:text_marquee/text_marquee.dart';
import '../color/AppColors.dart';
import '../HrDashboard/AddEmployees.dart';
import 'Screens/AssignedTask.dart';
import 'Screens/TaskAssign.dart';
import 'Screens/TaskStatusListPage.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.AdminThemeBackColor,
        appBar: AppBar(
          title: Text('Admin Dashboard', style: TextStyle(color: Colors.white),),
          backgroundColor: AppColors.userPrimaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.notifications)),
            IconButton(onPressed: (){}, icon: Icon(Icons.logout)),
          ],
        ),
        body: Dashboard()
    );
  }
}


class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      body: Column(
        children: [
          _buildUpdateBoard(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 0),
              children: [
                _buildCard(
                    AssetImage('assets/images/add_employee.png'),
                    'Add Employees',
                    Colors.white12,
                        (){
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeeForm()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/task_assign.png'),
                    'Task Assign',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskAssignmentForm()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/assigned_task.png'),
                    'Assigned Task',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AssignedTask()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/status.png'),
                    'Task Status',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskStatusListPage()));
                    }
                ),
              ],
            ),
          ),
          _buildFullWidthCard(context),
        ],
      ),
    );
  }

  Widget _buildCard(
      ImageProvider<Object> image,
      String text,
      Color bgColor,
      VoidCallback onPressed, // Function parameter for onPressed
      ) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: GestureDetector(
        onTap: onPressed, // Trigger onPressed function when tapped
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthCard(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.only(left: 12,right: 12, top: 8,bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: showingSections(),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildIndicator('Total Tasks', Colors.blue),
                _buildIndicator('Total Employees', Colors.red),
                _buildIndicator('Total Projects', Colors.green),
                _buildIndicator('Total Clients', Colors.yellow),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = false;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 40.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: 3,
            title: '3',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: 12,
            title: '12',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.green,
            value: 8,
            title: '8',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.yellow,
            value: 2,
            title: '2',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  Widget _buildIndicator(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

Widget _buildUpdateBoard() {
  return Container(
    width: double.infinity,
    height: 30,
    color: Colors.blueAccent,
    child: TextMarquee(
      'Daily Hr updates Herer *Updated* *Updated* *Updated* *Updated* *Updated* *Updated* *Updated* *Updated* *Updated* *Updated*',
      spaceSize: 72,
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontStyle: FontStyle.italic,
      ),
      duration: Duration(seconds: 12),
      delay: Duration(seconds: 1),
      rtl: true,
      startPaddingSize: 50,
    )
  );
}