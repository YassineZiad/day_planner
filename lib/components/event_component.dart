import 'package:flutter/material.dart';

import 'package:day_planner/configs/app_config.dart';
import 'package:day_planner/configs/theme_config.dart';
import 'package:day_planner/dialogs/event_dialog.dart';
import 'package:day_planner/dialogs/event_update_dialog.dart';
import 'package:day_planner/models/event.dart';
import 'package:day_planner/repositories/event_repository.dart';

/// Widget d'affichage des [Event]
///
/// [Event] display widget
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

/// Etat du widget [EventComponent]
///
/// State of [EventComponent] widget
class _EventComponentState extends State<EventComponent> {

  late Event _event;
  late double _height, _top, _width;
  late bool _canSave;
  late bool _hasBeenExtended, _hasBeenDeplaced;

  /// Retourne la durée de l'évènement
  ///
  /// Returns event duration
  double getTimePeriod() {
    double startTime = (_event.startDt.hour * 60 + _event.startDt.minute).toDouble() * (DayPlannerConfig.hourRowSize / 60);
    double endTime = (_event.endDt.hour * 60 + _event.endDt.minute).toDouble() * (DayPlannerConfig.hourRowSize / 60);
    return endTime - startTime;
  }

  /// Retourne un [Event] correspondant au nouvel intervalle de temps définit par l'utilisateur.
  /// Converti la taille de [EventComponent] en temps.
  ///
  /// Returns a [Event] with the new time interval defined by the user.
  /// Converts the size of a [EventComponent] to an event time range.
  Event getEventTimeRange(Event event, double top, double height, BuildContext context) {

    // Calcul de l'heure de début de l'évènement
    // Calculate event start time
    int startHour = (top / DayPlannerConfig.hourRowSize).floor();
    int startMinute = ((top % DayPlannerConfig.hourRowSize) / DayPlannerConfig.hourRowSize * 60).round();
    DateTime newStartDt = DateTime(event.startDt.year, event.startDt.month, event.startDt.day, startHour, startMinute);

    // Calcul de l'heure de fin de l'évènement
    // Calculate event end time
    double endPosition = top + height;
    int endHour = (endPosition / DayPlannerConfig.hourRowSize).floor();
    int endMinute = ((endPosition % DayPlannerConfig.hourRowSize) / DayPlannerConfig.hourRowSize * 60).round();
    DateTime newEndDt = DateTime(event.endDt.year, event.endDt.month, event.endDt.day, endHour, endMinute);

    // Création du nouvel évènement avec les nouvelles valeurs de temps
    // Create the new event with the new time values
    Event e = Event(
      id: event.id,
      summary: event.summary,
      startDt: newStartDt,
      endDt: newEndDt
    );

    return e;
  }

  /// Appelle la fonction de mise à jour d'un [Event] dans [EventRepository].
  /// Retourne l'évènement modifié s'il n'y a pas d'erreurs sinon retourne l'évènement sans changement.
  ///
  /// Calls the [Event] update function in [EventRepository].
  /// Returns the modified event if there are no errors, otherwise returns the same event unchanged.
  Future<Event> updateEvent(e) async {
    bool r = await EventRepository.updateEvent(e);
    if (r) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changement sauvegardé !")));
      return e;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur: L'évènement chevauche un autre évènement, est trop court, ou sort de la journée")));
      return _event;
    }
  }

  @override
  void initState() {
    super.initState();

    _event = widget.event;

    // Définit de la taille du composant à partir des valeurs de temps de l'événement
    // Setting the component size out of the event time values
    _height = getTimePeriod();
    _top = (widget.event.startDt.hour * 60 + widget.event.startDt.minute).toDouble() * (DayPlannerConfig.hourRowSize / 60);
    _width = 600;

    _canSave = false;

    _hasBeenDeplaced = false;
    _hasBeenExtended = false;
  }

  @override
  Widget build(BuildContext context) {
    _width = DayPlannerConfig.eventsColumnWidth(context);

    return Positioned(
        top: _top,
        left: 120,
        child: GestureDetector(
            onVerticalDragUpdate: (details) {
              // En cas de déplacement de l'évènement par l'utilisateur
              // When the event is moved by the user
              setState(() {
                // Récupération du nouveau placement de l'évènement
                // Gets the event new offset
                _top += details.delta.dy;
                _canSave = true;

                _hasBeenDeplaced = true;
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
                          if (e != null) {
                            setState(()  {_event = e;});
                          }
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
                                  style: TextStyle(color: Theme.of(context).extension<Palette>()!.lightKey, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start
                              ),
                              Visibility(
                                  visible: _canSave,
                                  child: IconButton(
                                      icon: const Icon(Icons.save),
                                      iconSize: 20,
                                      onPressed: () {
                                        // L'affichage du dialog EventUpdate se fait seulement en cas de déplacement de l'évènement par un utilisateur
                                        // Sinon, une modification normale s'exécute
                                        // EventUpdateDialog displays only when the event has been moved by the user
                                        // Otherwise, the event is modified normally
                                        if (_hasBeenDeplaced && !_hasBeenExtended) {
                                          EventUpdateDialog.show(getEventTimeRange(_event, _top, _height, context), _event, context).then((e) {
                                            widget.getEvents();
                                          });
                                        } else {
                                          updateEvent(getEventTimeRange(_event, _top, _height, context)).then((e) {
                                            setState(() {
                                              _event = e;
                                            });
                                          });
                                        }

                                        _canSave = false;
                                      }
                                  )
                              )
                            ],
                          ),
                          GestureDetector(
                              onVerticalDragUpdate: (details) {
                                // En cas d'extension de l'évènement par l'utilisateur
                                // When the event is extended by the user
                                setState(() {
                                  // Récupération de la nouvelle hauteur de l'évènement
                                  // Gets the event new height
                                  _height += details.delta.dy;
                                  _canSave = true;
                                  _hasBeenExtended = true;
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
