// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AdminElevationDialog extends StatefulWidget {
  final AppUser user;
  final String correctAdminPassword;

  const AdminElevationDialog({super.key, required this.user, required this.correctAdminPassword});

  @override
  _AdminElevationDialogState createState() => _AdminElevationDialogState();
}

class _AdminElevationDialogState extends State<AdminElevationDialog> {
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  void _elevateToAdmin() async {
    if (_passwordController.text == widget.correctAdminPassword) {
      await widget.user.updateAdminStatus(true);
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Become an Admin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Admin Password',
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          onPressed: _elevateToAdmin,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}