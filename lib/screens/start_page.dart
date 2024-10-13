import 'package:flutter/material.dart';
import 'login_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rbuy')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Refill as a Service', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Icon(Icons.bluetooth, size: 50, color: Colors.blue),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Start'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}