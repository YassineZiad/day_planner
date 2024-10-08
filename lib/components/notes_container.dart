import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:day_planner/configs/theme_config.dart';
import 'package:day_planner/components/task_component.dart';
import 'package:day_planner/dialogs/calendar_dialog.dart';
import 'package:day_planner/dialogs/event_dialog.dart';
import 'package:day_planner/models/note.dart';
import 'package:day_planner/models/task.dart';
import 'package:day_planner/repositories/note_repository.dart';
import 'package:day_planner/repositories/task_repository.dart';

/// Widget d'affichage des notes et tâches
///
/// Display widget for notes and tasks
class NotesContainer extends StatefulWidget {

  final DateTime day;
  final List<Task> normalTasks;
  final List<Task> priorityTasks;
  final Function getEvents;

  const NotesContainer({
    super.key,
    required this.day,
    required this.normalTasks,
    required this.priorityTasks,
    required this.getEvents
  });

  @override
  _NotesContainerState createState() => _NotesContainerState();
}

/// Etat de [NotesContainer]
///
/// State of [NotesContainer]
class _NotesContainerState extends State<NotesContainer> {

  static final TextEditingController _noteController = TextEditingController();

  late bool _noteChanged;
  late String _noteBackup;

  @override
  void initState() {
    super.initState();
    initContent();
  }

  void initContent() {
    NoteRepository.getNote(DateFormat('yyyy-MM-dd').format(widget.day)).then((value)
    {
      if (value != null) {
        _noteController.text = value.text;
      } else {
        _noteController.text = "";
      }
    });

    _noteBackup = _noteController.text;
    _noteChanged = false;
  }

  static Future<bool> isNoteNew(DateTime day) async {
    Note? n = await NoteRepository.getNote(DateFormat('yyyy-MM-dd').format(day));
    return n == null;
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 20;

    if (!_noteChanged) {
      initContent();
    }

    return Container(
        margin: defaultTargetPlatform == TargetPlatform.android ? const EdgeInsets.only(top: 60) : const EdgeInsets.only(left:30, top: 60),
        width: defaultTargetPlatform == TargetPlatform.android ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 3,
        child: Column(children: [

          // Ajout tâche
          // Adding task
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text("Ajouter un évènement"),
                  onPressed: () async {
                    EventDialog(create: true, day: widget.day).show(context).then((v) => widget.getEvents());
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_task),
                  label: const Text("Ajouter une tâche"),
                  onPressed: () async {
                    Task t = Task(label: "Nouvelle Tâche", done: false, priority: false, day: DateFormat('yyyy-MM-dd').format(widget.day));
                    t = await TaskRepository.createTask(t);
                    setState(() {
                      widget.normalTasks.add(t);
                    });
                  },
                )
              ],
            ),
          ),

          // Taches prioritaires
          // Priority tasks
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.priority_high),
                    Text("\t TACHES PRIORITAIRES",
                      style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start
                      ),
                  ],
                ),
              ])
          ),
          for (Task priorityTask in widget.priorityTasks) TaskComponent(task: priorityTask),
          DragTarget<Task>(
            builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
              return Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).extension<Palette>()!.secondary,
                child: const Center(
                  child: Icon(Icons.move_down),
                ),
              );
            },
            onAcceptWithDetails: (DragTargetDetails<Task> details) async {
              // Passage de tâche normale à proritaire
              // Switching task from standard to priority
              Task t = details.data;
              if (!t.priority) {
                t.priority = true;
                bool b = await TaskRepository.updateTask(t);
                setState(() {
                  if (b) {
                    widget.normalTasks.remove(details.data);
                    widget.priorityTasks.add(details.data);
                  }
                });
              }
            },
          ),

          // Tâches normales
          // Standard tasks
          Padding(
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.task),
                    Text("\t TACHES A EFFECTUER",
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start),
                  ],
                ),
              ])),
          for (Task normalTask in widget.normalTasks) TaskComponent(task: normalTask),
          DragTarget<Task>(
            builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
              return Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).extension<Palette>()!.secondary,
                child: const Center(
                  child: Icon(Icons.move_down),
                ),
              );
            },
            onAcceptWithDetails: (DragTargetDetails<Task> details) async {
              // Passage de tâche prioriataire à normale
              // Switching task from priority to standard
              Task t = details.data;
              if (t.priority) {
                t.priority = false;
                bool b = await TaskRepository.updateTask(t);
                if (b) {
                  setState(() {
                    widget.priorityTasks.remove(details.data);
                    widget.normalTasks.add(details.data);
                  });
                }
              }
            },
          ),

          const Padding(padding: EdgeInsets.only(bottom: 20)),
          // Suppression d'une tâche
          // Task deletion
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(child: DragTarget<Task>(
                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                    return Container(
                      height: 50,
                      color: Theme.of(context).extension<Palette>()!.secondary,
                      child: const Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Envoyer à un autre jour"), Icon(Icons.calendar_month)])
                      ),
                    );
                  },
                  onAcceptWithDetails: (DragTargetDetails<Task> details) async {
                    Task t = details.data;
                    DateTime? pickedDate = await showDialog<DateTime>(
                        context: context,
                        builder: (context) => CalendarDialog(date: widget.day)
                    );

                    // Si l'action s'est bien effectuée, on supprime la tâche de sa liste
                    // Deleting task from its list if the action has been correctly performed
                    if (pickedDate != null) {
                      t.day = DateFormat('yyyy-MM-dd').format(pickedDate);
                      bool b = await TaskRepository.updateTask(t);
                      setState(() {
                        details.data.priority && b ? widget.priorityTasks.remove(details.data) : widget.normalTasks.remove(details.data);
                      });
                    }

                  },
                )),
                Expanded(child: DragTarget<Task>(
                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                    return Container(
                      height: 50,
                      color: Theme.of(context).extension<Palette>()!.cancelled,
                      child: const Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Supprimer"), Icon(Icons.delete_sweep)]),
                      ),
                    );
                  },
                  onAcceptWithDetails: (DragTargetDetails<Task> details) async {
                    bool b = await TaskRepository.deleteTask(details.data);
                    setState(() {
                      details.data.priority && b ? widget.priorityTasks.remove(details.data) : widget.normalTasks.remove(details.data);
                    });
                  },
                ))
              ],
            ),
          ),


          // Notes
          Padding(
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.notes),
                    Text("\t NOTES",
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start
                    )
                  ],
                ),
                TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _noteController,
                    onTap: () => _noteBackup = _noteController.text,
                    onChanged: (v) {
                      setState(() {
                        _noteChanged = true;
                      });
                    }
                ),
                Visibility(
                    visible: _noteChanged,
                    child: Row(
                      children: [
                        TextButton.icon(
                          label: const Text("Sauvegarder"),
                          icon: const Icon(Icons.save),
                          onPressed: () async {
                            bool isNew = await isNoteNew(widget.day);
                            if (_noteController.text.isNotEmpty) {
                              Note n = Note(day: DateFormat('yyyy-MM-dd').format(widget.day), text: _noteController.text);
                              isNew ? NoteRepository.createNote(n) : NoteRepository.updateNote(n);
                            } else if (!isNew) {
                              NoteRepository.deleteNote(DateFormat('yyyy-MM-dd').format(widget.day));
                            }

                            setState(() {
                              _noteChanged = false;
                            });
                          },
                        ),
                        TextButton.icon(
                          label: const Text("Annuler"),
                          icon: const Icon(Icons.undo),
                          onPressed: () {
                            setState(() {
                              _noteController.text = _noteBackup;
                              _noteChanged = false;
                            });
                          },
                        )
                      ],
                    )
                )
              ]
              )
          ),
        ])
    );
  }

}