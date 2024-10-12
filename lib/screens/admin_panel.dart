import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'login_page.dart';

class AdminPanel extends StatefulWidget {
  final AppUser user;

  AdminPanel({required this.user});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Implement logout functionality
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement functionality to add new user or perform admin action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Admin action placeholder')),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Perform Admin Action',
      ),
    );
  }
}