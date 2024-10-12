import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import '../theme_notifier.dart';
import 'login_page.dart';
import 'search_kiosk_page.dart';
import 'help_page.dart';
import 'order_history_page.dart';
import 'notifications_page.dart';
import 'admin_elevation_dialog.dart';
import 'admin_panel.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  AppUser user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _unreadNotifications = 0;
  late AnimationController _leafController;
  late Animation<double> _leafAnimation;
  int _currentQuoteIndex = 0;
  late AnimationController _orbitalController;

  final List<String> _quotes = [
    "The greatest threat to our planet is the belief that someone else will save it.",
    "There is no such thing as 'away'. When we throw anything away it must go somewhere.",
    "We don't need a handful of people doing zero waste perfectly. We need millions of people doing it imperfectly.",
    "Refill, not landfill.",
    "Small changes can make a big difference.",
  ];

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
    _setupAnimations();
    _scheduleQuoteChange();
  }

  void _setupAnimations() {
    _leafController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _leafAnimation = CurvedAnimation(parent: _leafController, curve: Curves.easeInOut);
    _leafController.repeat(reverse: true);

    _orbitalController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  void _scheduleQuoteChange() {
    Future.delayed(const Duration(seconds: 10), _changeQuote);
  }

  void _changeQuote() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
    });
    _scheduleQuoteChange();
  }

  void _listenToNotifications() {
    NotificationService.getNotifications().listen((snapshot) {
      setState(() {
        _unreadNotifications = snapshot.docs.where((doc) => doc['read'] == false).length;
      });
    });
  }

  void _showAdminElevationDialog() async {
    final String correctAdminPassword = "admin123"; // You should store this securely
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AdminElevationDialog(
        user: widget.user,
        correctAdminPassword: correctAdminPassword,
      ),
    );

    if (result == true) {
      // Refresh the user object
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .get();
      setState(() {
        widget.user = AppUser.fromDocument(userDoc);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are now an admin!')),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Dark Mode'),
                trailing: Consumer<ThemeNotifier>(
                  builder: (context, themeNotifier, child) {
                    return Switch(
                      value: themeNotifier.themeMode == ThemeMode.dark,
                      onChanged: (bool value) {
                        themeNotifier.toggleTheme();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
              // Add more settings options here
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _leafController.dispose();
    _orbitalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildOrbitalAnimation(),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildOrbitalAnimation() {
    return AnimatedBuilder(
      animation: _orbitalController,
      builder: (context, child) {
        return CustomPaint(
          painter: OrbitalPainter(_orbitalController.value),
          child: Container(),
        );
      },
    );
  }

AppBar _buildAppBar() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final iconColor = isDarkMode ? Colors.white : Colors.deepPurple;

  return AppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 0,
    title: Text(
      'Rbuy',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: iconColor,
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.person, color: iconColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
          );
        },
      ),
      _buildNotificationButton(iconColor),
      IconButton(
        icon: Icon(Icons.settings, color: iconColor),
        onPressed: _showSettingsDialog,
      ),
      IconButton(
        icon: Icon(Icons.logout, color: iconColor),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      ),
    ],
  );
}
  
 Widget _buildNotificationButton(Color iconColor) {
  return Stack(
    children: <Widget>[
      IconButton(
        icon: Icon(Icons.notifications, color: iconColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
      ),
      if (_unreadNotifications > 0)
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minWidth: 14,
              minHeight: 14,
            ),
            child: Text(
              '$_unreadNotifications',
              style: const TextStyle(color: Colors.white, fontSize: 8),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  );
}
  Widget _buildLogoutButton() {
    return IconButton(
      icon: Icon(Icons.logout, color: Theme.of(context).primaryColor),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildWelcomeText(),
                const SizedBox(height: 30),
                _buildAnimatedEcoIcon(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
        _buildQuoteCard(),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'Welcome, ${widget.user.name}!',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildAnimatedEcoIcon() {
    return Center(
      child: AnimatedBuilder(
        animation: _leafAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _leafAnimation.value * 2 * pi / 60,
            child: Icon(Icons.eco, size: 120, color: Theme.of(context).primaryColor),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionButton(
            icon: Icons.search,
            label: 'Search for Kiosk',
            color: Colors.deepPurple,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchKioskPage())),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: Icons.help_outline,
            label: 'Help',
            color: Colors.deepPurple[400]!,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpPage())),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            icon: Icons.history,
            label: 'Order History',
            color: Colors.deepPurple[300]!,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryPage())),
          ),
          if (widget.user.isAdmin) ...[
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.admin_panel_settings,
              label: 'Admin Panel',
              color: Colors.red[400]!,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPanel(user: widget.user))),
            ),
          ],
          if (!widget.user.isAdmin) ...[
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.admin_panel_settings,
              label: 'Become an Admin',
              color: Colors.deepPurple[200]!,
              onPressed: _showAdminElevationDialog,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed, required Color color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.5),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          _quotes[_currentQuoteIndex],
          key: ValueKey<int>(_currentQuoteIndex),
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class OrbitalPainter extends CustomPainter {
  final double animation;

  OrbitalPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width < size.height ? size.width / 2 : size.height / 2;

    for (int i = 0; i < 5; i++) {
      final radius = maxRadius * (0.3 + (i * 0.14));
      final startAngle = (animation * 2 * pi) + (i * pi / 5);
      final sweepAngle = pi * 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      final endAngle = startAngle + sweepAngle;
      final endPoint = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );

      final circlePaint = Paint()
        ..color = Colors.deepPurple.withOpacity(0.5 + (0.5 * sin(animation * 2 * pi)))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endPoint, 5.0 + (3.0 * sin(animation * 2 * pi)), circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}