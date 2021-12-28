import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';
import 'notification_data.dart';
import 'sql_constants.dart';
import 'sql_lite_repository.dart';

class NotificationDisplay extends StatefulWidget {
  final SqfLiteRepository localDb;
  const NotificationDisplay({
    Key? key,
    required this.localDb,
  }) : super(key: key);

  @override
  State<NotificationDisplay> createState() => _NotificationDisplayState();
}

class _NotificationDisplayState extends State<NotificationDisplay>
    with WidgetsBindingObserver {
  List<NotificationData> notifications = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for showing notification on foreground',
    importance: Importance.max,
  );

  @override
  void initState() {
    FirebaseMessaging.instance.subscribeToTopic('Test');

    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    flutterLocalNotificationsPlugin.initialize(InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS));

    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotifications);
    FirebaseMessaging.onMessage.listen(handleForegroundNotification);

    getNotificationFromDBAndRefresh();

    super.initState();

    WidgetsBinding.instance?.addObserver(this);
  }

  void getNotificationFromDBAndRefresh() {
    widget.localDb.queryTable(notificationTableName).then((value) {
      var localNotifications = value.map((notification) {
        return NotificationData.fromJson(notification);
      }).toList();

      setState(() {
        notifications.clear();
        notifications.addAll(localNotifications);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return notifications.isEmpty
        ? const Center(
            child: Text('No notifications received'),
          )
        : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (_itemContext, _index) => Card(
              child: ListTile(
                key: Key(
                  _index.toString(),
                ),
                title: Text(notifications[_index].title),
                leading: const Icon(
                  Icons.notifications_active,
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: Text(notifications[_index].date)),
                    Expanded(
                      child: Text(
                        notifications[_index].time.split('.').first,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  void handleForegroundNotification(
    RemoteMessage event,
  ) {
    var notificationData = NotificationData(
      event.data['title'] ?? "-",
      event.data['date'] ?? "-",
      event.data['time'] ?? "-",
    );
    widget.localDb.insertDataTable(
      notificationTableName,
      [
        notificationData.toJson(),
      ],
    );

    setState(() {
      notifications.add(notificationData);
    });

    var notification = event.notification;
    AndroidNotification? android = event.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getNotificationFromDBAndRefresh();
    }
  }
}
