import 'package:day_planner_web/components/calendar_dialog.dart';
import 'package:day_planner_web/components/settings_dialog.dart';
import 'package:day_planner_web/models/event.dart';
import 'package:flutter/material.dart';

class EventComponent extends StatelessWidget {

  final Event event;
  final Color color;

  const EventComponent({
    super.key,
    required this.event,
    required this.color
  });

  double getTimePeriod() {
    double startTime = (event.startDt.hour * 60 + event.startDt.minute).toDouble();
    double endTime = (event.endDt.hour * 60 + event.endDt.minute).toDouble();
    return endTime - startTime;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: (event.startDt.hour * 60 + event.startDt.minute).toDouble(),
        left: 120,
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () {
              CalendarDialog.calendarDialogBuilder(context);
            },
            child: Container(
                padding: const EdgeInsets.only(right: 300),
                height: getTimePeriod(),
                decoration: BoxDecoration(
                    color: color,
                    border: const Border(
                        top: BorderSide(),
                        right: BorderSide(),
                        bottom: BorderSide())),
                child: Row(children: [
                  Text(event.summary,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start),
                  IconButton(
                      onPressed: () =>
                          CalendarDialog.calendarDialogBuilder(context),
                      icon: Icon(Icons.edit_calendar))
                ])
            )
        )
    );
  }
}