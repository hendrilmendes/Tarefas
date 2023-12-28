import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/tarefas/tarefas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUser();
    _loadTasks();
  }

  void _checkUser() async {
    final user = await _authService.currentUser();
    setState(() {
      _user = user;
    });
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        String newTaskTitle = '';

        return AlertDialog(
          title: const Text('Adicionar Tarefa'),
          content: TextField(
            onChanged: (value) {
              newTaskTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Adicione a nova tarefa ao Firestore
                await tasksCollection.add({
                  'title': newTaskTitle,
                  'completed': false,
                  'userId': _user!.uid,
                });

                // Recarregue as tarefas da nuvem
                _loadTasks();

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _loadTasks() {
    tasks.clear();

    if (_user != null) {
      tasksCollection
          .where('userId', isEqualTo: _user!.uid)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          tasks.add(Task(
            title: doc['title'],
            completed: doc['completed'],
          ));
        }
        setState(() {});
      });
    } else {
      if (kDebugMode) {
        print('Usuário nulo ao carregar tarefas.');
      }
    }
  }

  void _removeTask(int index) async {
    if (_user == null) {
      return;
    }

    final taskId = tasks[index].title;

    try {
      if (kDebugMode) {
        print('Deleting task: $taskId');
      }

      // Retrieve the document ID from Firestore based on the title
      final querySnapshot = await tasksCollection
          .where('userId', isEqualTo: _user!.uid)
          .where('title', isEqualTo: taskId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // Delete the document using the retrieved document ID
        await tasksCollection.doc(docId).delete();

        setState(() {
          tasks.removeAt(index);
        });

        if (kDebugMode) {
          print('Task removed from Firestore: $taskId');
        }
      } else {
        // Handle case where the document is not found
        if (kDebugMode) {
          print('Task not found in Firestore: $taskId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _authService.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nenhuma tarefa encontrada',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(tasks[index].title),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removeTask(index);
                  },
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    title: Text(tasks[index].title),
                    trailing: Checkbox(
                      value: tasks[index].completed,
                      onChanged: (value) {
                        setState(() {
                          tasks[index].completed = value!;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTask();
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
