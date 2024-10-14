import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../services/push_notification_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late PushNotificationService _pushNotificationService;

  @override
  void initState() {
    super.initState();
    _pushNotificationService = PushNotificationService();
    _pushNotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(context);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyWidget(context);
          }

          final groupedNotifications = _groupNotificationsByDate(snapshot.data!.docs);

          return ListView.builder(
            itemCount: groupedNotifications.length,
            itemBuilder: (context, index) {
              final date = groupedNotifications.keys.elementAt(index);
              final notifications = groupedNotifications[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(context, date),
                  ...notifications.map((doc) => _buildNotificationTile(context, doc)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.somethingWentWrong,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Trigger a rebuild of the StreamBuilder
              setState(() {});
            },
            child: Text(AppLocalizations.of(context)!.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotifications,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        DateFormat.yMMMd().format(date),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteNotification(context, document.reference),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: AppLocalizations.of(context)!.delete,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          data['body'] ?? data['message'],
          style: TextStyle(
            fontWeight: data['read'] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(DateFormat.jm().format(data['timestamp'].toDate())),
        leading: CircleAvatar(
          backgroundColor: data['read'] ? Colors.grey : Theme.of(context).primaryColor,
          child: Icon(
            data['read'] ? Icons.drafts : Icons.mail,
            color: Colors.white,
          ),
        ),
        onTap: () => _markAsRead(context, document.reference, data['read']),
      ),
    );
  }

  Map<DateTime, List<DocumentSnapshot>> _groupNotificationsByDate(List<DocumentSnapshot> docs) {
    return groupBy<DocumentSnapshot, DateTime>(docs, (doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      return DateTime(date.year, date.month, date.day);
    });
  }

  void _markAsRead(BuildContext context, DocumentReference reference, bool isRead) {
    reference.update({'read': true});
    if (!isRead) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.markedAsRead)),
      );
    }
  }

  void _deleteNotification(BuildContext context, DocumentReference reference) {
    reference.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.notificationDeleted)),
    );
  }

  void _markAllAsRead(BuildContext context) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'read': true});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.allNotificationsRead)),
      );
    });
  }
}

// Helper function to group list elements
Map<K, List<T>> groupBy<T, K>(Iterable<T> items, K Function(T) key) {
  return Map.fromIterable(
    items.map(key).toSet(),
    value: (k) => items.where((i) => key(i) == k).toList(),
  );
}