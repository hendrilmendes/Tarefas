import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      showDialog(
        context: context,
        builder: (context) {
          String newTaskTitle = '';

          return AlertDialog(
            title: Text(appLocalizations.newTask),
            content: TextFormField(
              decoration:
                  InputDecoration(labelText: appLocalizations.inputTask),
              maxLines: null,
              onChanged: (value) {
                newTaskTitle = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(appLocalizations.cancel),
              ),
              FilledButton.tonal(
                onPressed: () async {
                  // Adicione a nova tarefa ao Firestore
                  await tasksCollection.add({
                    'title': newTaskTitle,
                    'completed': false,
                    'userId': _user!.uid,
                  });

                  setState(() {
                    tasks.add(
                      Task(
                        title: newTaskTitle,
                        completed: false,
                      ),
                    );
                  });

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: Text(appLocalizations.salve),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadTasks() async {
    tasks.clear();

    if (_user != null) {
      final querySnapshot =
          await tasksCollection.where('userId', isEqualTo: _user!.uid).get();

      for (var doc in querySnapshot.docs) {
        tasks.add(Task(
          title: doc['title'],
          completed: doc['completed'],
        ));
      }
    } else {
      if (kDebugMode) {
        print('Usuário nulo ao carregar tarefas.');
      }
    }
  }

  void _updateTaskCompletion(int index, bool completed) async {
    if (_user == null) {
      return;
    }

    final taskId = tasks[index].title;

    try {
      final querySnapshot = await tasksCollection
          .where('userId', isEqualTo: _user!.uid)
          .where('title', isEqualTo: taskId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await tasksCollection.doc(docId).update({
          'completed': completed,
        });

        setState(() {
          tasks[index].completed = completed;
        });

        if (kDebugMode) {
          print('Estado de conclusão da tarefa atualizado: $taskId');
        }
      } else {
        if (kDebugMode) {
          print('Tarefa não encontrada Firestore: $taskId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar estado de conclusão da tarefa: $e');
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
        print('Apagando task: $taskId');
      }

      final querySnapshot = await tasksCollection
          .where('userId', isEqualTo: _user!.uid)
          .where('title', isEqualTo: taskId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await tasksCollection.doc(docId).delete();

        setState(() {
          tasks.removeAt(index);
        });

        if (kDebugMode) {
          print('Task removida Firestore: $taskId');
        }
      } else {
        if (kDebugMode) {
          print('Task nao encontrada Firestore: $taskId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao apagar task: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
      ),
      body: FutureBuilder<void>(
        future: _loadTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorLoadTask),
            );
          } else {
            return tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.noTask,
                          style: const TextStyle(fontSize: 18),
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
                              _updateTaskCompletion(index, value!);
                            },
                          ),
                        ),
                      );
                    },
                  );
          }
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
