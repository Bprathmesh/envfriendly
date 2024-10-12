import 'package:flutter/material.dart';
import 'dart:async';
import 'product_page.dart';

class SearchKioskPage extends StatefulWidget {
  @override
  _SearchKioskPageState createState() => _SearchKioskPageState();
}

class _SearchKioskPageState extends State<SearchKioskPage> {
  List<String> kiosks = [];

  @override
  void initState() {
    super.initState();
    searchKiosks();
  }

  void searchKiosks() {
    Timer(Duration(seconds: 2), () {
      setState(() {
        kiosks = ['Kiosk 1', 'Kiosk 2', 'Kiosk 3', 'Kiosk 4'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Kiosk')),
      body: kiosks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: kiosks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(kiosks[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductPage()),
                    );
                  },
                );
              },
            ),
    );
  }
}