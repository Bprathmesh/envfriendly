import 'package:flutter/material.dart';
import 'login_page.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rbuy')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Refill as a Service', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Icon(Icons.bluetooth, size: 50, color: Colors.blue),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Start'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}