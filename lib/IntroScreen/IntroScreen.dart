import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_sheet/LoginPage/LoginAsHr.dart';
import 'package:time_sheet/LoginPage/LoginAsManager.dart';

import '../LoginPage/LoginPage.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final List<String> imgList = [
    'assets/images/hr.jpg',
    'assets/images/manager.jpg',
    'assets/images/employee.jpg',
  ];

  final List<String> textList = [
    'Human Resources',
    'Manager',
    'Employee',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome',
              style: TextStyle(color: Colors.white, fontSize: 50),
            ),
            SizedBox(height: 8),
            Text(
              'DSD Systems Pvt. Ltd.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 80),
            Center(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 400.0,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                  autoPlayAnimationDuration: Duration(seconds: 1),
                  autoPlay: true,
                ),
                items: imgList.asMap().entries.map((entry) {
                  int index = entry.key;
                  String imageUrl = entry.value;
                  return GestureDetector(
                    onTap: (){

                      if(index == 0)
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> HrLoginScreen()));
                        }
                      else if(index==1){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ManagerLoginScreen()));
                      }
                      else if(index ==2)
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeLoginScreen()));
                        }
                      },
                    child: CardWidget(imageUrl, textList[index]),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeLoginScreen()));
              },
              child: Text('Login', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(340),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Color(0xFF698CED),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class CardWidget extends StatelessWidget {
  final String imageUrl;
  final String text;

  CardWidget(this.imageUrl, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      child: Card(
        color: Color(0xFF000066),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage(imageUrl),
                child: ClipOval(
                  child: Image.asset(imageUrl, fit: BoxFit.cover, width: 200, height: 200),
                ),
              ),
              SizedBox(height: 18),
              Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}