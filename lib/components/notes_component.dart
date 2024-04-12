import 'package:day_planner/models/note.dart';
import 'package:day_planner/repositories/note_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotesComponent extends StatefulWidget {

  DateTime day;

  NotesComponent({
    super.key,
    required this.day
  });

  @override
  _NoteComponentState createState() => _NoteComponentState();

}

class _NoteComponentState extends State<NotesComponent> {

  static TextEditingController noteController = TextEditingController();

  late bool _changed;
  late String _noteBackup;

  void initContent() {
    NoteRepository.getNote(DateFormat('yyyy-MM-dd').format(widget.day)).then((value) =>
    {
      if (value != null) {
        noteController.text = value.text
      } else {
        noteController.text = ""
      }
    });

    _noteBackup = noteController.text;
    _changed = false;
  }

  @override
  void initState() {
    super.initState();
    initContent();
  }

  static Future<bool> isNoteNew(DateTime day) async {
    Note? n = await NoteRepository.getNote(DateFormat('yyyy-MM-dd').format(day));
    return n == null;
  }

  @override
  Widget build(BuildContext context) {
    double _fontSize = 20;

    if (!_changed) {
      initContent();
    }

    return Container(
        margin: const EdgeInsets.only(left:30, top: 60),
        width: MediaQuery.of(context).size.width / 3,
        //decoration: const BoxDecoration(border: Border(top: BorderSide(), left: BorderSide(), right: BorderSide(), bottom: BorderSide())),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.priority_high),
                    Text("\t TACHES PRIORITAIRES",
                        style: TextStyle(
                            fontSize: _fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start)
                  ],
                ),

              ])),
          Padding(
              padding: const EdgeInsets.only(top: 200, left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.task),
                    Text("\t TACHES A EFFECTUER",
                        style: TextStyle(
                            fontSize: _fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start)
                  ],
                ),

              ])),
          Padding(
              padding: const EdgeInsets.only(top: 200, left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.notes),
                    Text("\t NOTES",
                        style: TextStyle(
                            fontSize: _fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start)
                  ],
                ),
                TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: noteController,
                    onTap: () => _noteBackup = noteController.text,
                    onChanged: (v) {
                      _changed = true;
                      setState(() {});
                    }
                ),
                Visibility(
                    visible: _changed,
                    child: Row(
                      children: [
                        TextButton.icon(
                          label: const Text("Sauvegarder"),
                          icon: const Icon(Icons.save),
                          onPressed: () async {
                            _changed = false;
                            if (noteController.text.isNotEmpty) {
                              bool isNew = await isNoteNew(widget.day);
                              Note n = Note(day: DateFormat('yyyy-MM-dd').format(widget.day), text: noteController.text);
                              isNew ? NoteRepository.createNote(n) : NoteRepository.updateNote(n);
                            } else {
                              NoteRepository.deleteNote(DateFormat('yyyy-MM-dd').format(widget.day));
                            }
                            setState(() {});
                          },
                        ),
                        TextButton.icon(
                          label: const Text("Annuler"),
                          icon: const Icon(Icons.undo),
                          onPressed: () {
                            noteController.text = _noteBackup;
                            _changed = false;
                            setState(() {});
                          },
                        )
                      ],
                    )
                )
              ]
              )
          ),
        ]
        )
    );
  }

}