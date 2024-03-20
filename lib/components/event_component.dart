import 'package:day_planner/repositories/event_repository.dart';
import 'package:flutter/material.dart';

import '../dialogs/event_dialog.dart';
import '../models/event.dart';

class EventComponent extends StatefulWidget {

  late Event event;
  final Color color;

  EventComponent({
    super.key,
    required this.event,
    required this.color
  });

  @override
  _EventComponentState createState() => _EventComponentState();
}

class _EventComponentState extends State<EventComponent> {

  late Event _event;
  late double _height;
  late double _top;
  late double _width;
  late bool _canSave;

  double getTimePeriod() {
    double startTime = (_event.startDt.hour * 60 + _event.startDt.minute).toDouble();
    double endTime = (_event.endDt.hour * 60 + _event.endDt.minute).toDouble();
    return endTime - startTime;
  }

  Future<Event> updateEvent(Event event, double top, double height, BuildContext context) async {
    TimeOfDay startT = TimeOfDay(
        hour: top ~/ 60,
        minute: (top % 60).round()
    );
    DateTime newStartDt = DateTime(event.startDt.year, event.startDt.month, event.startDt.day, startT.hour, startT.minute);

    TimeOfDay endT = TimeOfDay(
        hour: (top + height) ~/ 60,
        minute: ((top + height) % 60).round()
    );
    DateTime newEndDt = DateTime(event.endDt.year, event.endDt.month, event.endDt.day, endT.hour, endT.minute);

    Event e = Event(
      id: event.id,
      summary: event.summary,
      startDt: newStartDt,
      endDt: newEndDt
    );

    bool r = await EventRepository.updateEvent(e);
    if (r) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changement sauvegardé !")));
      return e;
    } else {
      return _event;
    }
  }

  @override
  void initState() {
    super.initState();

    _event = widget.event;

    _height = getTimePeriod();
    _top = (widget.event.startDt.hour * 60 + widget.event.startDt.minute).toDouble();
    _width = 600;

    _canSave = false;
  }

  @override
  Widget build(BuildContext context) {

    return Positioned(
        top: _top,
        left: 120,
        child: GestureDetector(
            onDoubleTap: () {
              EventDialog(create: false, event: _event).loginDialogBuilder(context);
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _top += details.delta.dy;
                _canSave = true;
              });
            },
            child: Container(
                height: _height,
                constraints: BoxConstraints(minWidth: _width, maxWidth: _width),
                decoration: BoxDecoration(
                    color: widget.color,
                    border: const Border(
                        top: BorderSide(),
                        right: BorderSide(),
                        bottom: BorderSide()
                    )
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Row(
                          children: [
                            Text(_event.summary,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start
                            ),
                            Visibility(
                                visible: _canSave,
                                child: IconButton(
                                  icon: const Icon(Icons.save),
                                  iconSize: 20,
                                  onPressed: () {
                                    _canSave = false;

                                    setState(() async {
                                      Event e = await updateEvent(_event, _top, _height, context);
                                      _event = e;
                                    });
                                  }
                                )
                            )
                          ],
                        ),
                        Container(
                            child: GestureDetector(
                              onVerticalDragUpdate: (details) {
                                setState(() {
                                  _height += details.delta.dy;
                                  _canSave = true;
                                });
                              },
                              child: const Icon(Icons.keyboard_arrow_down)
                            )
                        )
                    ]
                )
            )
        )
    );
  }
}
