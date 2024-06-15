import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../configs/app_config.dart';
import '../configs/theme_config.dart';
import '../models/event.dart';
import '../repositories/event_repository.dart';

class EventUpdateDialog extends StatefulWidget{

  Event newEvent;
  Event oldEvent;

  EventUpdateDialog({
    super.key,
    required this.newEvent,
    required this.oldEvent
  });

  @override
  State<StatefulWidget> createState() => _EventUpdateDialogState();

  static Future<void> show(Event newEvent, Event oldEvent, BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return EventUpdateDialog(newEvent: newEvent, oldEvent: oldEvent);
      },
    );
  }

}

class _EventUpdateDialogState extends State<EventUpdateDialog> {

  int? _choice = 0;
  bool _createNewEvent = false;

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _startMinuteController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();
  final TextEditingController _endMinuteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Modification de l'évènement"),
      children: [
        const Text("Choisir une option"),

        ListTile(
          title: Text('Laisser l\'emplacement vide', style: TextStyle(fontSize: AppConfig.fontSize)),
          leading: Radio<int>(
            value: 0,
            groupValue: _choice,
            onChanged: (int? value) {
              setState(() {
                _choice = value;
                _createNewEvent = false;
              });
            },
          ),
        ),

        ListTile(
          title: Text('Créer un nouvel évènement à la place', style: TextStyle(fontSize: AppConfig.fontSize)),
          leading: Radio<int>(
            value: 1,
            groupValue: _choice,
            onChanged: (int? value) {
              setState(() {
                _choice = value;
                _createNewEvent = true;
              });
            },
          ),
        ),
        if (_createNewEvent)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  child: TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(labelText: 'Libellé'),
                  ),
                ),
                /*Row(
                  children: [
                    const Text("Début: "),
                    SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _startHourController,
                          onChanged: (val) {
                            if (val.isNotEmpty) {
                              if (int.parse(val) >= 24) {
                                _startHourController.text = "23";
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        )
                    ),
                    Text(":", style: TextStyle(fontSize: AppConfig.fontSize)),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _startMinuteController,
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            if (int.parse(val) >= 60) {
                              _startMinuteController.text = "59";
                            }
                          }
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    const Text("Fin: "),
                    SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _endHourController,
                          onChanged: (val) {
                            if (val.isNotEmpty) {
                              if (int.parse(val) >= 24) {
                                _endHourController.text = "23";
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        )
                    ),
                    Text(":", style: TextStyle(fontSize: AppConfig.fontSize)),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _endMinuteController,
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            if (int.parse(val) >= 60) {
                              _endMinuteController.text = "59";
                            }
                          }
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),

        ListTile(
          title: Text('Remonter tous les évènements suivants.', style: TextStyle(fontSize: AppConfig.fontSize)),
          leading: Radio<int>(
            value: 2,
            groupValue: _choice,
            onChanged: (int? value) {
              setState(() {
                _choice = value;
                _createNewEvent = false;
              });
            },
          ),
        ),


        Row(
          children: [
            ElevatedButton(
              child: const Text("Modifier"),
              onPressed: () async {
                bool r;

                switch(_choice) {
                  case 1:
                    // Créer un nouvel évènement par dessus
                    // DateTime dt = widget.event.startDt;
                    // DateTime startDt = DateTime(dt.year, dt.month, dt.day, int.parse(_startHourController.text), int.parse(_startMinuteController.text));
                    // DateTime endDt = DateTime(dt.year, dt.month, dt.day, int.parse(_endHourController.text), int.parse(_endMinuteController.text));

                    var newEvent = Event(
                        id: widget.newEvent.id,
                        summary: _labelController.text,
                        startDt: widget.newEvent.startDt,
                        endDt: widget.newEvent.endDt,
                        userId: widget.newEvent.userId
                    );
                    r = await EventRepository.updateEventReplace(newEvent, widget.oldEvent);
                    break;

                  case 2:
                    // Remonter tous les évènements suivants
                    r = await EventRepository.updateEventMove(widget.newEvent);
                    break;

                  case 0:
                  default:
                    // Modifier
                    r = await EventRepository.updateEvent(widget.newEvent);
                    break;
                }

                if (r) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changement effectué !")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur: Chevauchement d'évènements ou évènement sorti de la journée.")));
                }
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
          ]
        ),
      ],
    );
  }

}

