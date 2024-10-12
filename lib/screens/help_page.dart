import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const ExpansionTile(
            title: Text('How do I find a kiosk?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You can find a kiosk by clicking on the "Search for Kiosk" button on the home page. This will show you a list of nearby kiosks.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('How do I place an order?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'After selecting a kiosk, you can choose a product and select the amount you want to refill. Follow the on-screen instructions to complete your order.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('What if I encounter an issue with my order?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'If you encounter any issues, please contact our customer support at support@rbuy.com or call us at 1-800-RBUY-HELP.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}