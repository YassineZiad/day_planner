// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:day_planner/components/current_time_line.dart';
import 'package:day_planner/components/event_component.dart';
import 'package:day_planner/extensions/object_extension.dart';
import 'package:day_planner/models/event.dart';
import 'package:day_planner/main.dart';

import 'test_app.dart';


void main() {

  /// Fonction vierge pour pouvoir appeler des widgets nécessitant une fonction en paramètres
  ///
  /// Empty function for calling widgets needing a function in parameters
  String _testFunction() => "";

  // Test de widget de l'affichage d'un EventComponent
  // Widget test of EventComponent display
  testWidgets('EventComponent display', (WidgetTester tester) async {
    DateTime testedDT = DateTime.now();
    Event event = Event(startDt: testedDT, endDt: testedDT.add(const Duration(hours: 2)), summary: "Evenement de test");
    await tester.pumpWidget(EventComponent(event: event, getEvents: _testFunction));

    final summaryFinder = find.text("Evenement de test");
    expect(summaryFinder, findsOneWidget);
  });

  // Test de widget de l'affichage de l'heure actuelle
  // Widget test of current time display
  testWidgets('Current hour display', (WidgetTester tester) async {
    DateTime testedDT = DateTime.now();
    await tester.pumpWidget(MyApp());

    final displayTimeFinder = find.text("${testedDT.hour.asTimeString()}:${testedDT.minute.asTimeString()}");
    expect(displayTimeFinder, findsOneWidget);

  });

  // Test de widget de l'affichage d'un EventComponent
  // Widget test of EventComponent display
  testWidgets('Disconnected display', (WidgetTester tester) async {
    await tester.pumpWidget(TestApp());

    final disconnectedFinder = find.text("Connectez-vous pour accéder à votre planner.");
    final connectedFinder = find.text("TACHES PRIORITAIRES");
    expect(disconnectedFinder, findsOneWidget);
    expect(connectedFinder, findsNothing);
  });
}
