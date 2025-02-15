import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/screens/notes/notes_details.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _noteController = TextEditingController();

  void _saveNote() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String noteText = _noteController.text.trim();
        if (noteText.isNotEmpty) {
          await FirebaseFirestore.instance.collection('notes').add({
            'userId': user.uid,
            'note': noteText,
            'timestamp': Timestamp.now(),
          });
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // ignore: use_build_context_synchronously
              content: Text(AppLocalizations.of(context)!.saveNote),
            ),
          );
          _noteController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.inputNoteError),
            ),
          );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // ignore: use_build_context_synchronously
          content: Text(AppLocalizations.of(context)!.errosaveNote),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notes,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[Expanded(child: NotesList())],
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
              decoration: InputDecoration(
                labelText: appLocalizations.inputNote,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withValues(),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withValues(),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withValues(),
                    width: 1.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
              ),
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
                child: Text(appLocalizations.save),
              ),
            ],
          );
        },
      );
    }
  }
}

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('notes')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid,
              )
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notes_rounded, size: 64),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noNotes,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(AppLocalizations.of(context)!.errorLoadNotes),
          );
        } else {
          final notes = snapshot.data!.docs;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            padding: const EdgeInsets.all(8.0),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note =
                  notes[index] as QueryDocumentSnapshot<Map<String, dynamic>>;
              return Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: NoteCard(note: note),
              );
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

  Future<void> _confirmDelete(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations!.confirmDelete),
          content: Text(appLocalizations.confirmDeleteSub),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(appLocalizations.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(appLocalizations.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(note.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note['note']),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)),
        );
      },
      onLongPress: () => _confirmDelete(context),
    );
  }
}
