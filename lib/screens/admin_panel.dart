import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/user_model.dart';
import 'login_page.dart';

class AdminPanel extends StatefulWidget {
  final AppUser user;

  const AdminPanel({super.key, required this.user});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late Stream<QuerySnapshot> _usersStream;
  final TextEditingController _notificationController = TextEditingController();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  int _userCount = 0;
  double _avgSessionDuration = 0;
  int _activeUsers = 0;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    // Get user count
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    _userCount = userSnapshot.size;

    // For demo purposes, we'll use random values for avg session duration and active users
    // In a real app, you'd fetch these from Firebase Analytics
    _avgSessionDuration = (DateTime.now().millisecondsSinceEpoch % 300).toDouble();
    _activeUsers = DateTime.now().day + 70;

    setState(() {});
  }

  Future<void> _sendNotification() async {
    if (_notificationController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'message': _notificationController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent successfully')),
      );
      _notificationController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
                'lastLogout': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ${widget.user.name}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          _buildAnalyticsSection(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _notificationController,
              decoration: const InputDecoration(
                labelText: 'Send Notification to All Users',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _sendNotification,
              child: const Text('Send Notification'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name'] ?? 'No name'),
                      subtitle: Text(data['email'] ?? 'No email'),
                      trailing: Icon(
                        data['isAdmin'] == true ? Icons.admin_panel_settings : Icons.person,
                        color: data['isAdmin'] == true ? Colors.red : Colors.blue,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Total Users: $_userCount'),
          Text('Avg. Session Duration: ${_avgSessionDuration.toStringAsFixed(2)} minutes'),
          Text('Active Users (last 30 days): $_activeUsers'),
        ],
      ),
    );
  }
}