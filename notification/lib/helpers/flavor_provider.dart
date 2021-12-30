import 'package:flutter/material.dart';

import 'flavor.dart';

class FlavorProvider extends InheritedWidget {
  final FlavorConfig flavorConfig;
  const FlavorProvider(
    this.flavorConfig, {
    child,
    key,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final Color color;

  FlavorConfig(this.flavor, this.name, this.color);
}
