// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import 'login_page.dart';
import 'package:animations/animations.dart';

class AdminPanel extends StatefulWidget {
  final AppUser user;

  const AdminPanel({super.key, required this.user});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late Stream<QuerySnapshot> _usersStream;
  final TextEditingController _notificationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  late TabController _tabController;
  
  int _userCount = 0;
  double _avgSessionDuration = 0;
  int _activeUsers = 0;
  int _newUsersLast7Days = 0;
  Map<String, int> _userEngagement = {};
  List<FlSpot> _chartData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAnalytics();
    _fetchChartData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => _isLoading = true);
    final userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    _userCount = userSnapshot.size;

    _avgSessionDuration = await _analytics.getSessionDuration() ?? 0;
    _activeUsers = await _analytics.getActiveUsers() ?? 0;
    _newUsersLast7Days = await _analytics.getNewUsers(7) ?? 0;
    _userEngagement = await _analytics.getUserEngagement() ?? {};

    setState(() => _isLoading = false);
  }

  Future<void> _fetchChartData() async {
    _chartData = [
      const FlSpot(0, 5),
      const FlSpot(1, 25),
      const FlSpot(2, 100),
      const FlSpot(3, 75),
      const FlSpot(4, 55),
      const FlSpot(5, 45),
      const FlSpot(6, 20),
    ];
    setState(() {});
  }

  void _onSearchChanged() {
    setState(() {
      _usersStream = FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: _searchController.text)
          .where('name', isLessThan: '${_searchController.text}z')
          .snapshots();
    });
  }

  Future<void> _sendNotification() async {
    if (_notificationController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Notification',
        'body': _notificationController.text,
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
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
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
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white.withOpacity(0.2),
              ),
              tabs: const [
                Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                Tab(icon: Icon(Icons.people), text: 'Users'),
                Tab(icon: Icon(Icons.settings), text: 'Controls'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnimatedTab(_buildAnalyticsTab()),
                _buildAnimatedTab(_buildUsersTab()),
                _buildAnimatedTab(_buildControlsTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTab(Widget child) {
    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchAnalytics();
        await _fetchChartData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsSection(),
            _buildEngagementSection(),
            _buildChartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsItem(Icons.people, 'Total Users', _userCount.toString()),
            _buildAnalyticsItem(Icons.timer, 'Avg. Session Duration', '${_avgSessionDuration.toStringAsFixed(2)} min'),
            _buildAnalyticsItem(Icons.trending_up, 'Active Users (30 days)', _activeUsers.toString()),
            _buildAnalyticsItem(Icons.person_add, 'New Users (7 days)', _newUsersLast7Days.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEngagementSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Engagement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._userEngagement.entries.map((e) => _buildEngagementItem(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly User Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Users',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          data['name']?[0] ?? '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(data['name'] ?? 'No name'),
                      subtitle: Text(data['email'] ?? 'No email'),
                      trailing: Switch(
                        value: data['isAdmin'] == true,
                        onChanged: (bool value) {
                          _toggleUserAdminStatus(document.id, data['isAdmin'] == true);
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Send Notification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notificationController,
                    decoration: InputDecoration(
                      labelText: 'Notification Message',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _sendNotification,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Notification'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Additional Controls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature flag toggled')),
                      );
                    },
                    icon: const Icon(Icons.toggle_on),
                    label: const Text('Toggle Feature Flags'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Database backup initiated')),
                      );
                    },
                    icon: const Icon(Icons.backup),
                    label: const Text('Backup Database'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
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