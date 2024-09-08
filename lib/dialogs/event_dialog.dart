import 'package:day_planner/extensions/object_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:day_planner/repositories/event_repository.dart';
import 'package:day_planner/configs/app_config.dart';
import 'package:day_planner/configs/theme_config.dart';
import 'package:day_planner/models/event.dart';

/// Dialog de création et de modification d'évènements
///
/// Dialog for creating and editing events
class EventDialog {

  Event? event;
  final bool create;
  DateTime day;

  EventDialog({
    this.event,
    required this.create,
    required this.day
  });

  static final _eventFormKey = GlobalKey<FormState>();
  static final TextEditingController _summaryController = TextEditingController();
  static final TextEditingController _startHourController = TextEditingController();
  static final TextEditingController _startMinuteController = TextEditingController();
  static final TextEditingController _endHourController = TextEditingController();
  static final TextEditingController _endMinuteController = TextEditingController();

  /// Retourne le nom du dialog en fonction de l'action effectuée
  ///
  /// Returns dialog name depending on the action performed
  String getDialogTitle() {
    return create ? "Créer un évènement" : "Modifier un évènement";
  }

  Future<void> show(BuildContext context) async {
    AlertDialog confirmDelete = AlertDialog(
      title: const Text("Supprimer"),
      content: const Text("Êtes-vous sûr de vouloir supprimer l'évènement ?"),
      icon: const Icon(Icons.delete_forever),
      actions: [
        TextButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).extension<Palette>()!.cancelled)),
          child: const Text("Supprimer"),
          onPressed:  () {
            EventRepository.deleteEvent(this.event!);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("Annuler"),
          onPressed:  () => Navigator.pop(context),
        )
      ],
    );

    DateTime dt = this.day;

    // Valeurs par défaut de saisie
    // Default input values
    _summaryController.text = create ? "" : event!.summary;

    _startHourController.text = create ? TimeOfDay.now().hour.asTimeString() : event!.startDt.hour.asTimeString();
    _startMinuteController.text = create ? TimeOfDay.now().minute.asTimeString() : event!.startDt.minute.asTimeString();

    int endHour = TimeOfDay.now().hour + 1 > 23 ? 23 : TimeOfDay.now().hour + 1;
    _endHourController.text = create ? endHour.asTimeString() : event!.endDt.hour.asTimeString();
    _endMinuteController.text = create ? TimeOfDay.now().minute.asTimeString() : event!.endDt.minute.asTimeString();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(getDialogTitle()),
          children: <Widget>[
            Form(
              key: _eventFormKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Titre'),
                      controller: _summaryController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Saisir un titre';
                        }
                        return null;
                      },
                    ),
                    Row(
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
                      Text(":", style: TextStyle(fontSize: DayPlannerConfig.fontSizeS)),
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
                      Text(":", style: TextStyle(fontSize: DayPlannerConfig.fontSizeS)),
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
                    ]),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_eventFormKey.currentState!.validate()) {
                              Event e = Event(
                                  summary: _summaryController.text,
                                  startDt: DateTime(dt.year, dt.month, dt.day, int.parse(_startHourController.text), int.parse(_startMinuteController.text)),
                                  endDt: DateTime(dt.year, dt.month, dt.day, int.parse(_endHourController.text), int.parse(_endMinuteController.text))
                              );

                              bool r;
                              if (create) {
                                r = await EventRepository.createEvent(e);
                              } else {
                                e.id = event!.id;
                                r = await EventRepository.updateEvent(e);
                              }

                              Navigator.pop(context);

                              if (r) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Effectué avec succès !")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur: Un évènement ne peut pas en chevaucher un autre.")));
                              }

                            }
                          },
                          child: const Text('Valider'),
                        ),
                        if (!create)
                          ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return confirmDelete;
                                  }
                              );
                            },
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).extension<Palette>()!.cancelled)),
                            child: const Text('Supprimer')
                          )
                      ],
                    )
                  ]
              )
            )
          ],
        );
      },
    );
  }

}