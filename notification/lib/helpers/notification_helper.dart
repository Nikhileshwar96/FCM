import 'package:firebase_messaging/firebase_messaging.dart';

import 'sql_lite_repository.dart';
import '../models/sql_constants.dart';
import '../models/notification_data.dart';

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
