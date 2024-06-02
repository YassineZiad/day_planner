import 'package:flutter/material.dart';

import '../configs/app_config.dart';
import '../configs/theme_config.dart';
import '../dialogs/event_dialog.dart';
import '../models/event.dart';
import '../repositories/event_repository.dart';

class EventComponent extends StatefulWidget {

  final Event event;
  final Function getEvents;

  const EventComponent({
    super.key,
    required this.event,
    required this.getEvents
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
    double startTime = (_event.startDt.hour * AppConfig.hourRowSize + _event.startDt.minute).toDouble();
    double endTime = (_event.endDt.hour * AppConfig.hourRowSize + _event.endDt.minute).toDouble();
    return endTime - startTime;
  }

  Future<Event> updateEvent(Event event, double top, double height, BuildContext context) async {

    TimeOfDay startT = TimeOfDay(
        hour: top ~/ AppConfig.hourRowSize,
        minute: (top % AppConfig.hourRowSize).round()
    );
    DateTime newStartDt = DateTime(event.startDt.year, event.startDt.month, event.startDt.day, startT.hour, startT.minute);

    TimeOfDay endT = TimeOfDay(
        hour: (top + height) ~/ AppConfig.hourRowSize,
        minute: ((top + height) % AppConfig.hourRowSize).round()
    );
    DateTime newEndDt = DateTime(event.endDt.year, event.endDt.month, event.endDt.day, endT.hour, endT.minute);

    print("${startT.hour}:${startT.minute}");
    print("${endT.hour}:${endT.minute}");

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur: Un évènement ne peut pas en chevaucher un autre.")));
      return _event;
    }
  }

  @override
  void initState() {
    super.initState();

    _event = widget.event;

    _height = getTimePeriod();
    _top = (widget.event.startDt.hour * AppConfig.hourRowSize + widget.event.startDt.minute).toDouble();
    _width = 600;

    _canSave = false;
  }

  @override
  Widget build(BuildContext context) {
    _width = AppConfig.eventsColumnWidth(context);

    return Positioned(
        top: _top,
        left: 120,
        child: GestureDetector(
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
                    color: Theme.of(context).extension<Palette>()!.tertiary,
                    border: const Border(
                        top: BorderSide(),
                        right: BorderSide(),
                        bottom: BorderSide()
                    )
                ),
                child: InkWell(
                    onTap: () {
                        EventDialog(create: false, event: _event, day: _event.startDt).show(context).then((v) {
                            EventRepository.getEventById(_event.id!).then((e) {
                              setState(()  {
                                _event = e;
                              });
                              widget.getEvents();
                            });

                        });
                    },
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

                                        updateEvent(_event, _top, _height, context).then((e) {
                                          setState(() {
                                            _event = e;
                                          });
                                        });
                                      }
                                  )
                              )
                            ],
                          ),
                          GestureDetector(
                              onVerticalDragUpdate: (details) {
                                setState(() {
                                  _height += details.delta.dy;
                                  _canSave = true;
                                });
                              },
                              child: const Icon(Icons.keyboard_arrow_down)
                          )
                        ]
                    )
                )
            )
        )
    );
  }
}
