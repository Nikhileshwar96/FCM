import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification/helpers/flavor_provider.dart';

import '../models/notification_data.dart';
import '../models/sql_constants.dart';
import '../helpers/sql_lite_repository.dart';
import '../helpers/notification_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  FirebaseFirestore firestore = FirebaseFirestore.instance;
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

    registerDeviceIDForNotifications();

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

  void registerDeviceIDForNotifications() async {
    var deviceId = await FirebaseMessaging.instance.getToken();

    if (deviceId == null) {
      return;
    }

    CollectionReference devices =
    FirebaseFirestore.instance.collection('devices');
    var registeredDevices = await devices.where('deviceID', isEqualTo: deviceId).get();
    if(registeredDevices.size > 0) {
      return;
    }

    devices.add({'deviceID': deviceId});
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
    var flavor = FlavorProvider.of(context);
    return notifications.isEmpty
        ? Center(
            child: Text('No notifications received in ${flavor.flavorConfig.name}'),
          )
        : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (_itemContext, _index) => Card(
              child: ListTile(
                key: Key(
                  _index.toString(),
                ),
                title: Text(notifications[_index].title),
                leading: Icon(
                  Icons.notifications_active,
                  color: flavor.flavorConfig.color,
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
