import 'package:flutter/material.dart';

import '../dialogs/event_dialog.dart';
import '../models/event.dart';

class BetterEventComponent extends StatefulWidget {

  final Event event;
  final Color color;

  const BetterEventComponent({
    super.key,
    required this.event,
    required this.color
  });

  @override
  _ResizableContainerState createState() => _ResizableContainerState();
}

class _ResizableContainerState extends State<BetterEventComponent> {

  double getTimePeriod() {
    double startTime = (widget.event.startDt.hour * 60 + widget.event.startDt.minute).toDouble();
    double endTime = (widget.event.endDt.hour * 60 + widget.event.endDt.minute).toDouble();
    return endTime - startTime;
  }

  late double _height;
  late double _top;
  late double _width;

  @override
  void initState() {
    super.initState();
    _height = getTimePeriod();
    _top = (widget.event.startDt.hour * 60 + widget.event.startDt.minute).toDouble();
    _width = 600;
  }

  @override
  Widget build(BuildContext context) {

    return Positioned(
        top: _top,
        left: 120,
        child: GestureDetector(
            onDoubleTap: () {
              EventDialog(create: false, event: widget.event).loginDialogBuilder(context);
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _top += details.delta.dy;
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
                      Text(widget.event.summary,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start),
                      Container(
                          child: GestureDetector(
                              onVerticalDragUpdate: (details) {
                                setState(() {
                                  _height += details.delta.dy;
                                });
                              },
                              child: Container(
                                //margin: EdgeInsets.only(left: ),
                                child: Icon(Icons.keyboard_arrow_down)
                              )
                          )
                      )
                    ]
                )
            )
        )
    );
  }
}
