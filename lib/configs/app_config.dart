import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConfig {

  static int hourRowSize = 60;
  static double eventsColumnWidth(BuildContext context) {
    return defaultTargetPlatform == TargetPlatform.android ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 2;
  }

  static double fontSize = 15;

}