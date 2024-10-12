import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['message']),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(data['timestamp'].toDate())),
                trailing: Icon(
                  data['read'] ? Icons.drafts : Icons.mail,
                  color: data['read'] ? Colors.grey : Colors.blue,
                ),
                onTap: () {
                  // Mark as read when tapped
                  document.reference.update({'read': true});
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}