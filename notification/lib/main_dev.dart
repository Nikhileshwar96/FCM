import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notification/helpers/flavor_provider.dart';
import 'package:notification/helpers/sql_lite_repository.dart';
import 'app.dart';
import 'firebase_options_dev.dart';

import 'helpers/flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var localDB = SqfLiteRepository();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var flavor = FlavorConfig(
    Flavor.dev,
    "dev",
    Colors.green,
  );

  runApp(App(
    flavor,
    localDb: localDB,
  ));
}
