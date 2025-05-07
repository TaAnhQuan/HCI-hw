import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

const AndroidNotificationDetails taskChannel = AndroidNotificationDetails(
  'task_channel',
  'messages',
  importance: Importance.max,
  priority: Priority.high,
  showWhen: false,
);

Future<void> showNotificationOfSummaryFinished() async {
  const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails();

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: taskChannel,
    iOS: iosPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'Buddie',
    'Your meeting summary has been finished.',
    platformChannelSpecifics,
  );
}

Future<void> showNotificationOfSummaryFailed() async {
  const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails();

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: taskChannel,
    iOS: iosPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    1,
    'Buddie',
    "There's an error during generating your meeting summary.",
    platformChannelSpecifics,
  );
}