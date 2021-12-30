import 'package:flutter/material.dart';
import 'package:notification/helpers/flavor_provider.dart';

import 'helpers/sql_lite_repository.dart';
import 'views/notification_display.dart';

class App extends StatelessWidget {
  final SqfLiteRepository localDb;
  final FlavorConfig flavor;
  const App(
    this.flavor, {
    Key? key,
    required this.localDb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlavorProvider(
      flavor,
      child: MaterialApp(
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
      ),
    );
  }
}
