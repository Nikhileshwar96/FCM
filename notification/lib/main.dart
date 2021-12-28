import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notification/sql_constants.dart';
import 'package:notification/sql_lite_repository.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_data.dart';
import 'notification_display.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var localDB = SqfLiteRepository();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(App(
    localDb: localDB,
  ));
}

class App extends StatelessWidget {
  final SqfLiteRepository localDb;
  const App({
    Key? key,
    required this.localDb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: NotificationDisplay(
            localDb: localDb,
          ),
        ),
      ),
    );
  }
}

Future<void> handleBackgroundNotifications(RemoteMessage message) async {
  var localDB = SqfLiteRepository();
  await localDB.checkIfInitialized();
  var notificationData = NotificationData(
    message.data['title'] ?? "-",
    message.data['date'] ?? DateTime.now().millisecondsSinceEpoch,
    message.data['time'] ?? DateTime.now().millisecondsSinceEpoch,
  );

  await localDB.insertDataTable(
    notificationTableName,
    [notificationData.toJson()],
  );
}
