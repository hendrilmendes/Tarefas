import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotasScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const NotasScreen({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _NotasScreenState createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final TextEditingController _noteController = TextEditingController();

  void _saveNote() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('notes').add({
          'userId': user.uid,
          'note': _noteController.text,
          'timestamp': Timestamp.now(),
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ignore: use_build_context_synchronously
            content: Text(AppLocalizations.of(context)!.salveNote),
          ),
        );
        _noteController.clear();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // ignore: use_build_context_synchronously
          content: Text(AppLocalizations.of(context)!.erroSalveNote),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notes),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: NotesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteDialog();
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }

  Future<void> _showAddNoteDialog() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.newNote),
            content: TextFormField(
              controller: _noteController,
              decoration:
                  InputDecoration(labelText: appLocalizations.inputNote),
              maxLines: null,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(appLocalizations.cancel),
              ),
              FilledButton.tonal(
                onPressed: () {
                  _saveNote();
                  Navigator.of(context).pop();
                },
                child: Text(appLocalizations.salve),
              ),
            ],
          );
        },
      );
    }
  }
}

class NotesList extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const NotesList({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.noNotes,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!.errorLoadNotes));
        } else {
          final notes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note =
                  notes[index] as QueryDocumentSnapshot<Map<String, dynamic>>;
              return NoteCard(note: note);
            },
          );
        }
      },
    );
  }
}

class NoteCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: Text(note['note']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailPage(note: note),
            ),
          );
        },
      ),
    );
  }
}

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
        title: Text(AppLocalizations.of(context)!.detailsNotes),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.note),
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
              child: Text(AppLocalizations.of(context)!.salve),
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
              },
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        ),
      ),
    );
  }
}
