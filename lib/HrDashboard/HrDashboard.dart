import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:time_sheet/HrDashboard/updateProjects.dart';
import '../color/AppColors.dart';
import 'AddEmployees.dart';
import 'AddNewProject.dart';
import 'AddProject.dart';
import 'LeaveRequest.dart';
import 'UpdateEmployee.dart';



class HrDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.AdminThemeBackColor,
        appBar: AppBar(
          title: Text('HR Dashboard', style: TextStyle(color: Colors.white),),
          backgroundColor: AppColors.userPrimaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.notifications)),
            IconButton(onPressed: (){}, icon: Icon(Icons.logout)),
          ],
        ),
        body: Dashboard(),
        floatingActionButtonAnimator: CustomFabAnimator(),

        floatingActionButton: GestureDetector(
          onLongPress: () {
         const snackBar = SnackBar(content: Text('announcement any updates'),duration: Duration(seconds: 2),shape: ContinuousRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),);
         ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => BottomSheetContent(),
              );
            }, // Add action on normal press if needed
            child: Icon(Icons.announcement,color: Colors.white,),
            backgroundColor: AppColors.userPrimaryColor,
          ),
        ),
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
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              padding: EdgeInsets.all(10.0),
              children: [
                _buildCard(
                    AssetImage('assets/images/add_employee.png'),
                    'Onboarding',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeeForm()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/task_assign.png'),
                    'Attendance',
                    Colors.white12,
                        (){
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskAssignmentForm()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/assigned_task.png'),
                    'Payroll',
                    Colors.white12,
                        (){
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> AssignedTask()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/updateEmployee.png'),
                    '   Update\nEmployees',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeePage()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/newProjects.png'),
                    'Add Projects',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AddProjectPage()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/leaveReq.png'),
                    'Leaves Request',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaveRequestsPage()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/updateProject.png'),
                    'Updates Projects',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateProjects()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/updates.png'),
                    'Add New Project',
                    Colors.white12,
                        (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AddNewProject()));
                    }
                ),
                _buildCard(
                    AssetImage('assets/images/logout.png'),
                    'Logout',
                    Colors.white12,
                        (){
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaveRequestsPage()));
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
        borderRadius: BorderRadius.circular(10.0),
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
                width: 40.0,
                height: 40.0,
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
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
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
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
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
      final radius = isTouched ? 60.0 : 50.0;
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



class CustomFabAnimator extends FloatingActionButtonAnimator {
  @override
  Offset getOffset({required Offset begin, required Offset end, required double progress}) {
    // Define custom animation logic for position
    return Offset.lerp(begin, end, progress) ?? begin;
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    // Define custom animation logic for scaling
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: parent,
        curve: Curves.elasticOut, // Use elasticOut curve for a bounce effect
      ),
    );
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    // Define custom animation logic for rotation
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: parent,
        curve: Curves.easeInOut,
      ),
    );
  }
}

class BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.userPrimaryLightColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "announcement any updates!!",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  labelText: "Enter Your Massage",
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.userPrimaryButtonColor,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  fixedSize: Size.fromWidth(
                      MediaQuery.sizeOf(context).width * 2),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Publish',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
