import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_sheet/color/AppColors.dart';

class LeaveRequestsPage extends StatefulWidget {
  @override
  _LeaveRequestsPageState createState() => _LeaveRequestsPageState();
}

class _LeaveRequestsPageState extends State<LeaveRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.userPrimaryLightColor,
      appBar: AppBar(
        backgroundColor: AppColors.userPrimaryColor,
        title: Text('Leave Requests', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requestLeave').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((doc) {
              return LeaveRequestCard(doc: doc);
            }).toList(),
          );
        },
      ),
    );
  }
}

class LeaveRequestCard extends StatelessWidget {
  final DocumentSnapshot doc;

  LeaveRequestCard({required this.doc});

  final TextEditingController _customMessageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${doc['Name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Profile: ${doc['Profile']}', style: TextStyle(fontSize: 16)),
            Text('Reason: ${doc['Reason']}', style: TextStyle(fontSize: 16)),
            Text('Start Date: ${doc['Start Date']}', style: TextStyle(fontSize: 16)),
            Text('End Date: ${doc['End Date']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateRequestStatus(doc.id, 'Approved'),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _updateRequestStatus(doc.id, 'Denied'),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showCustomMessageDialog(context, doc.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateRequestStatus(String docId, String status) {
    FirebaseFirestore.instance.collection('requestLeave').doc(docId).update({'status': status});
  }

  void _showCustomMessageDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Custom Message'),
          content: TextField(
            controller: _customMessageController,
            decoration: InputDecoration(labelText: 'Enter your message'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _customMessageController.clear();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                FirebaseFirestore.instance.collection('requestLeave').doc(docId).update({
                  'custom_message': _customMessageController.text,
                });
                Navigator.of(context).pop();
                _customMessageController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}
