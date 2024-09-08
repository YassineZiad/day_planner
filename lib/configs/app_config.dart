import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Contient des variables réutilisables pour les widgets de l'application comme des tailles.
class DayPlannerConfig {

  static int hourRowSize = 60;
  static double eventsColumnWidth(BuildContext context) {
    return defaultTargetPlatform == TargetPlatform.android ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 2;
  }

  static double fontSizeS = 15;
  static double fontSizeM = 20;
  static double fontSizeL = 25;
}