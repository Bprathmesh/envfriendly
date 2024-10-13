import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../theme_notifier.dart';
import '../language_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_nameController.text != widget.user.name) {
      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
        'name': _nameController.text,
      });
      setState(() {
        widget.user.name = _nameController.text;
      });
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildUserInfo(),
              const SizedBox(height: 20),
              _buildStatistics(),
              const SizedBox(height: 20),
              _buildAchievements(),
              const SizedBox(height: 20),
              _buildSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.user.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          _isEditing
              ? TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name,
                  ),
                )
              : Text(
                  widget.user.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(AppLocalizations.of(context)!.email, widget.user.email),
            _buildInfoItem(AppLocalizations.of(context)!.accountType, widget.user.isAdmin ? AppLocalizations.of(context)!.admin : AppLocalizations.of(context)!.user),
            _buildInfoItem(AppLocalizations.of(context)!.memberSince, _formatDate(widget.user.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.statistics, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildStatItem(AppLocalizations.of(context)!.totalOrders, '23'),
            _buildStatItem(AppLocalizations.of(context)!.totalSavings, '₹450'),
            _buildStatItem(AppLocalizations.of(context)!.plasticSaved, '2.3 kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.achievements, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge(Icons.eco, AppLocalizations.of(context)!.ecofriendly),
                _buildBadge(Icons.loyalty, AppLocalizations.of(context)!.loyalCustomer),
                _buildBadge(Icons.trending_up, AppLocalizations.of(context)!.trendSetter),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.settings, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.darkMode),
              value: themeNotifier.isDarkMode,
              onChanged: (bool value) {
                themeNotifier.toggleTheme();
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.language),
              trailing: DropdownButton<String>(
                value: languageNotifier.currentLanguage,
                items: [
                  DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)!.english)),
                  DropdownMenuItem(value: 'kn', child: Text(AppLocalizations.of(context)!.kannada)),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    languageNotifier.setLocale(Locale(value, ''));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}