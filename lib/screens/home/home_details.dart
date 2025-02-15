import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/widgets/custom_textfield.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeDetailsScreen extends StatefulWidget {
  final Task task;

  const HomeDetailsScreen({super.key, required this.task});

  @override
  // ignore: library_private_types_in_public_api
  _HomeDetailsScreenState createState() => _HomeDetailsScreenState();
}

class _HomeDetailsScreenState extends State<HomeDetailsScreen> {
  late TextEditingController _controller;
  late DateTime? _selectedDateTime;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);
    _selectedDateTime = widget.task.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.taskDetails,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ModernTextField(
                controller: _controller,
                label: AppLocalizations.of(context)!.inputTask,
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        _selectedDateTime ?? DateTime.now(),
                      ),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
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
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(100.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDateTime != null
                              ? DateFormat(
                                'dd/MM/yyyy - HH:mm',
                              ).format(_selectedDateTime!)
                              : AppLocalizations.of(context)!.dateTime,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context)!.delete,
                icon: const Icon(Icons.delete_outlined),
                onPressed: () {
                  _delete();
                },
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.save,
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () {
                  final newTitle = _controller.text.trim();
                  if (newTitle.isNotEmpty) {
                    final updatedTask = Task(
                      title: newTitle,
                      completed: widget.task.completed,
                      id: widget.task.id,
                      dateTime: _selectedDateTime,
                    );
                    _updateTask(updatedTask);
                  }
                },
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.share,
                icon: const Icon(Icons.share_outlined),
                onPressed: _shareTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
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

      if (confirm != true) {
        return;
      }

      try {
        final taskId = widget.task.title;

        final querySnapshot =
            await tasksCollection
                .where('userId', isEqualTo: _user!.uid)
                .where('title', isEqualTo: taskId)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final docId = querySnapshot.docs.first.id;
          await tasksCollection.doc(docId).delete();

          FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
              FlutterLocalNotificationsPlugin();
          await flutterLocalNotificationsPlugin.cancel(widget.task.id.hashCode);

          if (kDebugMode) {
            print('Tarefa removida Firestore: $taskId');
          }

          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(true);
        } else {
          if (kDebugMode) {
            print('Tarefa não encontrada no Firestore: $taskId');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao apagar tarefa: $e');
        }
      }
    }
  }

  void _shareTask() {
    final formattedDate =
        _selectedDateTime != null
            ? DateFormat('dd/MM/yyyy - HH:mm').format(_selectedDateTime!)
            : AppLocalizations.of(context)!.noDate;

    Share.share(
      '${AppLocalizations.of(context)!.taskTitle}: ${widget.task.title}\n'
      '${AppLocalizations.of(context)!.dateTitle}: $formattedDate',
    );
  }

  void _updateTask(Task updatedTask) async {
    if (kDebugMode) {
      print('Atualizando tarefa: $updatedTask');
    }

    if (updatedTask.title != widget.task.title ||
        updatedTask.completed != widget.task.completed ||
        updatedTask.dateTime != widget.task.dateTime) {
      if (kDebugMode) {
        print('Detalhes da tarefa atualizados: $updatedTask');
      }

      try {
        final taskDoc = await tasksCollection.doc(widget.task.id).get();
        await taskDoc.reference.update({
          'title': updatedTask.title,
          'completed': updatedTask.completed,
          'dateTime': updatedTask.dateTime,
        });

        if (kDebugMode) {
          print('Notificação agendada para: ${updatedTask.dateTime}');
        }

        const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Lembretes de Tarefas',
            icon: '@drawable/ic_notification',
            channelDescription: 'Alertas de tarefas agendadas',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(),
        );

        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        await flutterLocalNotificationsPlugin.zonedSchedule(
          updatedTask.id.hashCode,
          updatedTask.title,
          // ignore: use_build_context_synchronously
          '${AppLocalizations.of(context)!.notificationTask}: ${updatedTask.title}',
          tz.TZDateTime.from(updatedTask.dateTime!, tz.local),
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } catch (e) {
        if (kDebugMode) {
          print('Error updating task: $e');
        }
      }
    } else {
      Navigator.pop(context);
    }
  }
}
