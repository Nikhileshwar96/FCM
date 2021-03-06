import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notification/helpers/sql_lite_repository.dart';
import 'app.dart';
import 'firebase_options.dart';

import 'helpers/flavor.dart';
import 'helpers/flavor_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var localDB = SqfLiteRepository();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var _prodFlavor = FlavorConfig(
    Flavor.prod,
    "prod",
    Colors.red,
  );

  runApp(App(
    _prodFlavor,
    localDb: localDB,
  ));
}
