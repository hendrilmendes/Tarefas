import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/tarefas/tarefas.dart';
import 'package:tarefas/widgets/botton_navigation.dart';
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
        title: Text(AppLocalizations.of(context)!.taskDetails),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.inputNote,
                border: const OutlineInputBorder(),
              ),
              maxLines: null,
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
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDateTime != null
                        ? DateFormat('dd/MM/yyyy - HH:mm')
                            .format(_selectedDateTime!)
                        : AppLocalizations.of(context)!.dateTime,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            FilledButton.tonal(
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
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
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
            'notification_id',
            'Tarefas',
            icon: '@drawable/ic_notification',
            channelDescription: 'Canal de notificações',
            importance: Importance.max,
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
          tz.TZDateTime.from(
            updatedTask.dateTime!,
            tz.getLocation('America/Manaus'),
          ),
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavigationContainer(),
          ),
        );
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
