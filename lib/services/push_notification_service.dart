import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission (required for iOS)
    await _fcm.requestPermission();

    // Configure FCM
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Listen for new notifications in Firestore
    FirebaseFirestore.instance
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _showNotification(change.doc.data() as Map<String, dynamic>);
        }
      }
    });
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _showNotification({
        'title': notification.title,
        'body': notification.body,
      });
    }
  }

  Future<void> _showNotification(Map<String, dynamic> notificationData) async {
    await _flutterLocalNotificationsPlugin.show(
      notificationData.hashCode,
      notificationData['title'],
      notificationData['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print("Handling a background message: ${message.messageId}");
}