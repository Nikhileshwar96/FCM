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

  static FlavorProvider of(BuildContext context) {
    final FlavorProvider? result = context.dependOnInheritedWidgetOfExactType<FlavorProvider>();
    assert(result != null, 'No Flavor found in context');
    return result!;
  }
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final Color color;

  FlavorConfig(this.flavor, this.name, this.color);
}
