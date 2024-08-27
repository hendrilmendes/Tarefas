import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class NoteDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> note;

  const NoteDetailPage({super.key, required this.note});

  @override
  // ignore: library_private_types_in_public_api
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.note['note'];
  }

  void _saveNote() {
    FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.note.id)
        .update({'note': _noteController.text});
    Navigator.pop(context);
  }

  void _deleteNote() {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.confirmDelete),
            content: Text(appLocalizations.confirmDeleteSub),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(appLocalizations.cancel),
              ),
              FilledButton.tonal(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('notes')
                      .doc(widget.note.id)
                      .delete();
                  Navigator.of(context).pop();
                },
                child: Text(appLocalizations.delete),
              ),
            ],
          );
        },
      );
    }
  }

  void _shareNote() {
    Share.share(widget.note['note']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notesDetails),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.inputNote,
                  border: const OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  tooltip: AppLocalizations.of(context)!.delete,
                  icon: const Icon(Icons.delete_outlined),
                  onPressed: () {
                    _deleteNote();
                    Navigator.of(context).pop();
                  }),
              IconButton(
                tooltip: AppLocalizations.of(context)!.save,
                icon: const Icon(Icons.save_alt),
                onPressed: _saveNote,
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.share,
                icon: const Icon(Icons.share_outlined),
                onPressed: _shareNote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
