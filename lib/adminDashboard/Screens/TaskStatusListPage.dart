import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_sheet/color/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../massage/MassageHandler.dart';
import '../../webView/WebViewPage.dart';

class TaskStatusListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        title: Text('Task Status List', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.userPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('TaskStatus').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No task statuses found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              var data = document.data() as Map<String, dynamic>;

              // Example: Customize color based on status
              Color statusColor = _getStatusColor(data['selectedStatus']);

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                child: ListTile(
                  title: Row(
                    children: [
                      _buildStatusIndicator(statusColor), // Status indicator circle
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data['selectedProject'] ?? 'Unknown Project',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 5),
                      Text('User Name: ${extractUsername(data['userEmail'] ?? "Unknown UserName")}'),
                      SizedBox(height: 5),
                      Text('Client: ${data['selectedClient'] ?? 'Unknown Client'}'),
                      SizedBox(height: 5),
                      Text('Category: ${data['selectedCategory'] ?? 'Unknown Category'}'),
                      SizedBox(height: 5),
                      Text('Status: ${data['selectedStatus'] ?? 'Unknown Status'}'),
                      SizedBox(height: 5),
                    ],
                  ),
                  // GitHub URL button positioned at bottom right
                  trailing: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: TextButton(onPressed: (){
                      String url = data["githubUrl"];
                      if(url.isNotEmpty){
                        WebViewPage(initialUrl: url,javascriptMode: JavaScriptMode.unrestricted, url: url,);
                      }else{
                        MessageHandler.showCustomMessage("URL not Found!!",backgroundColor: Colors.grey);
                      }

                    },child: Text("Check Code!!", style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),),),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  void _launchURL(String url) async {
    try {
      Uri uri = Uri.parse(url);
      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  String extractUsername(String email) {
    int atIndex = email.indexOf('@');
    String username = email.substring(0, atIndex);
    if (username.isNotEmpty) {
      username = username[0].toUpperCase() + username.substring(1);
    }
    return username;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'to do':
        return Colors.redAccent;
      case 'in progress':
        return Colors.orangeAccent;
      case 'blocked':
        return Colors.yellowAccent;
      case 'under review':
        return Colors.lightBlueAccent;
      case 'completed':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.grey;
      case 'on hold':
        return Colors.deepPurpleAccent;
      default:
        return Colors.blueGrey;
    }
  }
}

