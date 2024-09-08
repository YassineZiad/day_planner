import 'package:flutter_test/flutter_test.dart';

import 'package:day_planner/components/event_component.dart';
import 'package:day_planner/models/event.dart';

import 'test_app.dart';

void main() {

  /// Fonction vierge pour pouvoir appeler des widgets nécessitant une fonction en paramètres
  ///
  /// Empty function for calling widgets needing a function in parameters
  String _testFunction() => "";

  test('EventComponent', () {
    final DateTime testedDT = DateTime.parse("2024-06-16 11:00:00");
    Event event = Event(summary: "Evènement de test", startDt: testedDT, endDt: testedDT.add(const Duration(hours: 3)));
    
    Event newEvent = TestApp().getEventTimeRange(event, 450, 800);

    expect(newEvent.startDt.hour, 7);
    expect(newEvent.startDt.minute, 30);
    expect(newEvent.endDt.hour, 20);
    expect(newEvent.endDt.minute, 50);
  });

}