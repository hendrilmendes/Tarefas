import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/tarefas/tarefas.dart';
import 'package:tarefas/telas/home/home_details.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  final List<Task> _pendingTasks = [];
  final List<Task> _completedTasks = [];
  int _taskIdCounter = 0;

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

    if (_user != null) {
      _loadTasks();
    } else {
      if (kDebugMode) {
        print('Usuário nulo ao carregar tarefas.');
      }
    }
  }

  Future<List<List<Task>>> _loadTasks() async {
    List<Task> pendingTasks = [];
    List<Task> completedTasks = [];

    if (_user != null) {
      final querySnapshot =
          await tasksCollection.where('userId', isEqualTo: _user!.uid).get();

      for (var doc in querySnapshot.docs) {
        final task = Task(
          title: doc['title'],
          completed: doc['completed'],
          id: doc.id,
          dateTime: (doc['dateTime'] as Timestamp).toDate(),
        );

        if (task.completed) {
          completedTasks.add(task);
        } else {
          pendingTasks.add(task);
        }
      }
    } else {
      if (kDebugMode) {
        print('Usuário nulo ao carregar tarefas.');
      }
    }

    return [pendingTasks, completedTasks];
  }

  Widget _buildTaskItem(Task task, bool isPending) {
    return Dismissible(
      key: Key(task.title),
      direction:
          isPending ? DismissDirection.endToStart : DismissDirection.endToStart,
      onDismissed: (direction) {
        _removeTask(task);
      },
      background: Container(
        alignment: isPending ? Alignment.centerRight : Alignment.centerRight,
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: ListTile(
        title: Text(task.title),
        onTap: () {
          if (isPending) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeDetailsScreen(
                task: task,
              ),
            ));
          }
        },
        trailing: isPending
            ? Checkbox(
                value: task.completed,
                onChanged: (value) {
                  _updateTaskCompletion(task, value!);
                },
              )
            : null,
      ),
    );
  }

  void _addTask() {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      showDialog(
        context: context,
        builder: (context) {
          String newTaskTitle = '';
          DateTime? taskDateTime;

          return AlertDialog(
            title: Text(appLocalizations.newTask),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration:
                      InputDecoration(labelText: appLocalizations.inputTask),
                  maxLines: null,
                  onChanged: (value) {
                    newTaskTitle = value;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        // ignore: use_build_context_synchronously
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          taskDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          // ignore: unnecessary_null_comparison
                          taskDateTime != null
                              ? DateFormat('dd/MM/yyyy - HH:mm')
                                  .format(taskDateTime)
                              : appLocalizations.dateTime,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                  if (taskDateTime != null) {
                    // Incrementando o contador para gerar um novo ID único
                    _taskIdCounter++;

                    final newTaskId = _taskIdCounter
                        .toString(); // Convertendo o contador para string

                    tasksCollection.add({
                      'title': newTaskTitle,
                      'completed': false,
                      'userId': _user!.uid,
                      'dateTime': taskDateTime,
                    });

                    // Agendar notificacao
                    const NotificationDetails notificationDetails =
                        NotificationDetails(
                      android: AndroidNotificationDetails(
                        'notification_id',
                        'Tarefas',
                        icon: '@drawable/ic_notification',
                        channelDescription: 'Canal de notificações',
                        importance: Importance.max,
                      ),
                      iOS: DarwinNotificationDetails(),
                    );

                    FlutterLocalNotificationsPlugin
                        flutterLocalNotificationsPlugin =
                        FlutterLocalNotificationsPlugin();

                    await flutterLocalNotificationsPlugin.zonedSchedule(
                      int.parse(newTaskId),
                      newTaskTitle,
                      '${appLocalizations.notificationTask}: $newTaskTitle',
                      tz.TZDateTime.from(
                        taskDateTime!,
                        tz.getLocation('America/Manaus'),
                      ),
                      notificationDetails,
                      uiLocalNotificationDateInterpretation:
                          UILocalNotificationDateInterpretation.absoluteTime,
                      androidScheduleMode:
                          AndroidScheduleMode.inexactAllowWhileIdle,
                    );

                    setState(() {
                      _pendingTasks.add(Task(
                        title: newTaskTitle,
                        completed: false,
                        id: newTaskId,
                        dateTime: taskDateTime,
                      ));
                    });

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(appLocalizations.error),
                          content: Text(appLocalizations.errorSub),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(appLocalizations.ok),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(appLocalizations.save),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateTaskCompletion(Task task, bool completed) async {
    if (_user == null) {
      return;
    }

    final taskId = task.title;

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
          task.completed = completed;
          if (completed) {
            _completedTasks.add(task);
            _pendingTasks.remove(task);
          } else {
            _pendingTasks.add(task);
            _completedTasks.remove(task);
          }
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

  void _removeTask(Task task) async {
    if (_user == null) {
      return;
    }

    final taskId = task.title;

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
          if (task.completed) {
            _completedTasks.remove(task);
          } else {
            _pendingTasks.remove(task);
          }
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
      body: FutureBuilder<List<List<Task>>>(
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
            final List<Task> pendingTasks = snapshot.data![0];
            final List<Task> completedTasks = snapshot.data![1];

            if (pendingTasks.isEmpty && completedTasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.noTask,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                if (pendingTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocalizations.of(context)!.pendants,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pendingTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskItem(pendingTasks[index], true);
                        },
                      ),
                    ],
                  ),
                if (completedTasks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocalizations.of(context)!.completed,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskItem(completedTasks[index], false);
                        },
                      ),
                    ],
                  ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
