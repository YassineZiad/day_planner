import 'package:flutter/material.dart';

import 'package:day_planner/configs/app_config.dart';
import 'package:day_planner/models/event.dart';
import 'package:day_planner/repositories/event_repository.dart';

/// Dialog d'options de modification d'un [Event].
/// Cette classe permet de proposer à l'utilisateur s'il souhaite ou non que la modification d'un [Event]
/// ait ou non une incidence sur les autres.
class EventUpdateDialog extends StatefulWidget {

  final Event newEvent;
  final Event oldEvent;

  const EventUpdateDialog({
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

/// Etat interne à [EventUpdateDialog]
class _EventUpdateDialogState extends State<EventUpdateDialog> {

  int? _choice = 0;
  bool _createNewEvent = false;

  static final TextEditingController _labelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Modification de l'évènement"),
      children: [
        const Text("Choisir une option"),

        ListTile(
          title: Text('Laisser l\'emplacement vide', style: TextStyle(fontSize: DayPlannerConfig.fontSizeS)),
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
          title: Text('Créer un nouvel évènement à la place', style: TextStyle(fontSize: DayPlannerConfig.fontSizeS)),
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
                )
              ],
            ),
          ),

        ListTile(
          title: Text('Déplacer tous les évènements de la même journée.', style: TextStyle(fontSize: DayPlannerConfig.fontSizeS)),
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
                    // Déplacer tous les évènements de la journée
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

