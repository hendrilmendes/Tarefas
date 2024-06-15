import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class NoteDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> note;
  final TextEditingController _noteController = TextEditingController();

  NoteDetailPage({super.key, required this.note}) {
    _noteController.text = note['note'];
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
              const SizedBox(height: 16.0),
              FilledButton.tonal(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('notes')
                      .doc(note.id)
                      .update({'note': _noteController.text});
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
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
                                    .doc(note.id)
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
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.delete),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Share.share(note['note']);
                },
                child: Text(AppLocalizations.of(context)!.share),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
