import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      await FirebaseFirestore.instance.collection('notes').add({
        'note': _noteController.text,
        'timestamp': Timestamp.now(),
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nota salva com sucesso!'),
        ),
      );
      _noteController.clear();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar nota.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anotações"),
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
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nova Anotação"),
          content: TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: "Digite sua anotação"),
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _saveNote();
                Navigator.of(context).pop();
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }
}

class NotesList extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const NotesList({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('notes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Nenhuma anotação encontrada 😅",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar notas"));
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
        title: const Text("Detalhes da Anotação"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: "Anotação"),
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
              child: const Text("Salvar"),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('notes')
                    .doc(note.id)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text("Excluir"),
            ),
          ],
        ),
      ),
    );
  }
}
