import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notification/helpers/flavor.dart';
import 'package:notification/helpers/flavor_provider.dart';
import 'package:notification/helpers/sql_lite_repository.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var localDB = SqfLiteRepository();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlavorConfig flavor = FlavorConfig(
    Flavor.stag,
    "Stag",
    Colors.yellow,
  );

  runApp(App(
    flavor,
    localDb: localDB,
  ));
}
