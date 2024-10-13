// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'product_page.dart';

class SearchKioskPage extends StatefulWidget {
  final String userId;

  const SearchKioskPage({super.key, required this.userId});

  @override
  _SearchKioskPageState createState() => _SearchKioskPageState();
}

class _SearchKioskPageState extends State<SearchKioskPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Kiosk> kiosks = [];
  final int totalKiosks = 9;
  final List<double> circleRadii = [80, 140, 200];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..forward();

    _controller.addListener(() {
      if (_controller.value < 1) {
        setState(() {
          int currentKiosks = (totalKiosks * _controller.value).ceil();
          while (kiosks.length < currentKiosks) {
            int circleIndex = kiosks.length % circleRadii.length;
            double angle = (kiosks.length / circleRadii.length) * (2 * pi / (totalKiosks / circleRadii.length));
            kiosks.add(Kiosk(
              x: circleRadii[circleIndex] * cos(angle),
              y: circleRadii[circleIndex] * sin(angle),
            ));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("Search Kiosk" , style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 420,
              height: 420,
              child: Stack(
                children: [
                  ...circleRadii.map((radius) => _buildCircle(radius)),
                  const Center(
                    child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
                  ),
                  ...kiosks.map((kiosk) => _buildKioskWidget(kiosk)).toList(),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Showing Nearby Kiosks",
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double radius) {
    return Center(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }

  Widget _buildKioskWidget(Kiosk kiosk) {
    return Positioned(
      left: 210 + kiosk.x,
      top: 210 + kiosk.y,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductPage(userId: widget.userId)),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_drink, color: Colors.white, size: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Kiosk {
  final double x;
  final double y;

  Kiosk({required this.x, required this.y});
}