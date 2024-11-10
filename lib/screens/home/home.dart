import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/auth/auth.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/screens/home/home_details.dart';
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
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  int _taskIdCounter = 0;
  String _loadingMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final user = await _authService.currentUser();
    setState(() {
      _user = user;
    });

    if (_user != null) {
      // Somente carregue as tarefas se ainda não tiverem sido carregadas
      if (_pendingTasks.isEmpty && _completedTasks.isEmpty) {
        _loadTasks();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (kDebugMode) {
        print('Usuário nulo ao carregar tarefas.');
      }
    }
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_user != null) {
        final querySnapshot =
            await tasksCollection.where('userId', isEqualTo: _user!.uid).get();

        final pendingTasks = <Task>[];
        final completedTasks = <Task>[];

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

        setState(() {
          _pendingTasks = pendingTasks;
          _completedTasks = completedTasks;
          _loadingMessage = '';
        });
      } else {
        if (kDebugMode) {
          print('Usuário nulo ao carregar tarefas.');
        }
      }
    } catch (e) {
      setState(() {
        _loadingMessage = 'Erro ao carregar as tarefas.';
      });
      if (kDebugMode) {
        print('Erro ao carregar as tarefas: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildTaskItem(Task task, bool isPending) {
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
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomeDetailsScreen(
                task: task,
              ),
            ),
          );
          if (result == true) {
            await _loadTasks();
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

  Future<bool> _addTask() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      String newTaskTitle = '';
      DateTime? taskDateTime;

      final bool? result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(appLocalizations.newTask),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: appLocalizations.inputTask,
                        labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                      ),
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
                              taskDateTime != null
                                  ? DateFormat('dd/MM/yyyy - HH:mm')
                                      .format(taskDateTime!)
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
                      Navigator.pop(context, false);
                    },
                    child: Text(appLocalizations.cancel),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      if (newTaskTitle.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(appLocalizations.error),
                              content: Text(appLocalizations.inputTaskError),
                              actions: <Widget>[
                                FilledButton.tonal(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(appLocalizations.ok),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (taskDateTime != null) {
                        _taskIdCounter++;
                        final newTaskId = _taskIdCounter.toString();

                        await tasksCollection.add({
                          'title': newTaskTitle,
                          'completed': false,
                          'userId': _user!.uid,
                          'dateTime': taskDateTime,
                        });

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
                              UILocalNotificationDateInterpretation
                                  .absoluteTime,
                          androidScheduleMode:
                              AndroidScheduleMode.inexactAllowWhileIdle,
                        );

                        if (context.mounted) {
                          Navigator.pop(context, true);
                          await _loadTasks(); // Atualiza as tarefas após salvar
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(appLocalizations.error),
                              content: Text(appLocalizations.inputDateError),
                              actions: <Widget>[
                                FilledButton.tonal(
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
        },
      );

      return result ?? false;
    }
    return false;
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
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      if (_user == null) {
        return;
      }

      final taskId = task.title;

      setState(() {
        if (task.completed) {
          _completedTasks.remove(task);
        } else {
          _pendingTasks.remove(task);
        }
      });

      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.confirmDelete),
            content: Text(appLocalizations.confirmDeleteTask),
            actions: <Widget>[
              TextButton(
                child: Text(appLocalizations.cancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FilledButton.tonal(
                child: Text(appLocalizations.delete),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);

      if (confirm != true) {
        // Se o usuário cancelar, readicione a tarefa na lista e recarregue as tarefas
        setState(() {
          if (task.completed) {
            _completedTasks.add(task);
          } else {
            _pendingTasks.add(task);
          }
        });
        await _loadTasks();
        return;
      }

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

      // Recarregar as tarefas após a confirmação e remoção
      await _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.appName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : _loadingMessage.isNotEmpty
              ? Center(
                  child: Text(_loadingMessage),
                )
              : (_pendingTasks.isEmpty && _completedTasks.isEmpty)
                  ? Center(
                      child: Text(
                        appLocalizations.noTask,
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView(
                      children: [
                        if (_pendingTasks.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  appLocalizations.pendants,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _pendingTasks.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    elevation: 3,
                                    child: buildTaskItem(
                                        _pendingTasks[index], true),
                                  );
                                },
                              ),
                            ],
                          ),
                        if (_completedTasks.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  appLocalizations.completed,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _completedTasks.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    elevation: 3,
                                    child: buildTaskItem(
                                        _completedTasks[index], false),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        elevation: 3,
        child: Icon(
          Icons.add_outlined,
        ),
      ),
    );
  }
}
