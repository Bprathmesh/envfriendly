import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import 'login_page.dart';

class AdminPanel extends StatefulWidget {
  final AppUser user;

  const AdminPanel({Key? key, required this.user}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late Stream<QuerySnapshot> _usersStream;
  final TextEditingController _notificationController = TextEditingController();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  late TabController _tabController;
  
  int _userCount = 0;
  double _avgSessionDuration = 0;
  int _activeUsers = 0;
  int _newUsersLast7Days = 0;
  Map<String, int> _userEngagement = {};
  List<FlSpot> _chartData = [];

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAnalytics();
    _fetchChartData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnalytics() async {
    // Fetch real analytics data
    final userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    _userCount = userSnapshot.size;

    // These would typically come from Firebase Analytics
    _avgSessionDuration = await _analytics.getSessionDuration() ?? 0;
    _activeUsers = await _analytics.getActiveUsers() ?? 0;
    _newUsersLast7Days = await _analytics.getNewUsers(7) ?? 0;
    _userEngagement = await _analytics.getUserEngagement() ?? {};

    setState(() {});
  }

  Future<void> _fetchChartData() async {
    // This would typically come from Firebase Analytics
    _chartData = [
      FlSpot(0, 5),
      FlSpot(1, 25),
      FlSpot(2, 100),
      FlSpot(3, 75),
      FlSpot(4, 55),
      FlSpot(5, 45),
      FlSpot(6, 20),
    ];

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

  Future<void> _toggleUserAdminStatus(String userId, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isAdmin': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.settings), text: 'Controls'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
                'lastLogout': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildUsersTab(),
          _buildControlsTab(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsSection(),
          _buildEngagementSection(),
          _buildChartSection(),
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
          const Text('Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Total Users: $_userCount'),
          Text('Avg. Session Duration: ${_avgSessionDuration.toStringAsFixed(2)} minutes'),
          Text('Active Users (last 30 days): $_activeUsers'),
          Text('New Users (last 7 days): $_newUsersLast7Days'),
        ],
      ),
    );
  }

  Widget _buildEngagementSection() {
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
          const Text('User Engagement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._userEngagement.entries.map((e) => Text('${e.key}: ${e.value}')),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Text(titles[value.toInt()]);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 120,
          lineBarsData: [
            LineChartBarData(
              spots: _chartData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
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
              trailing: Switch(
                value: data['isAdmin'] == true,
                onChanged: (bool value) {
                  _toggleUserAdminStatus(document.id, data['isAdmin'] == true);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildControlsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _notificationController,
            decoration: const InputDecoration(
              labelText: 'Send Notification to All Users',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sendNotification,
            child: const Text('Send Notification'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Implement feature flag toggle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature flag toggled')),
              );
            },
            child: const Text('Toggle Feature Flags'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Implement database backup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database backup initiated')),
              );
            },
            child: const Text('Backup Database'),
          ),
        ],
      ),
    );
  }
}

// Mock Firebase Analytics methods (replace these with actual implementations)
extension AnalyticsMethods on FirebaseAnalytics {
  Future<double?> getSessionDuration() async {
    // Implement actual analytics query
    return 15.5;
  }

  Future<int?> getActiveUsers() async {
    // Implement actual analytics query
    return 1000;
  }

  Future<int?> getNewUsers(int days) async {
    // Implement actual analytics query
    return 50;
  }

  Future<Map<String, int>?> getUserEngagement() async {
    // Implement actual analytics query
    return {
      'Daily Active Users': 500,
      'Weekly Active Users': 2000,
      'Monthly Active Users': 5000,
    };
  }
}