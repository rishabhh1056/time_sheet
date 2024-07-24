import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_sheet/LoginScreen/LoginAsEmployee.dart';

import '../LoginScreen/LoginScreen.dart';
import '../adminDashboard/adminDashboard.dart';
import '../main.dart';
import '../userDashboard/userDashboard.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Align(alignment: Alignment.center, child: Text('Time Sheet', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24)),),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.settings))
        ],
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.exit_to_app), ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),minimumSize: Size(MediaQuery.sizeOf(context).width /1.8, 300)),
              onPressed: () {
                // Navigate to User Dashboard
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),

                child: Column(
                  children: [
                    Image.asset("assets/images/user.png", height: 100),
                    SizedBox(height: 10),
                    Text('Admin',style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),minimumSize: Size(MediaQuery.sizeOf(context).width /1.8, 300)),
              onPressed: () {
                // Navigate to User Dashboard
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeLoginScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),

                child: Column(
                  children: [
                    Image.asset("assets/images/hr.jpg", height: 100),
                    SizedBox(height: 10),
                    Text('User',style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



Widget _buildCard(
    ImageProvider<Object> image,
    String text,
    Color bgColor,
    VoidCallback onPressed, // Function parameter for onPressed
    ) {
  return Card(
    elevation: 3.0,
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
              width: 100.0,
              height: 100.0,
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
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
