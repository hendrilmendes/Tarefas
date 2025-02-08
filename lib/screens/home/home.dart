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
  final List<Task> _pendingTasks = [];
  final List<Task> _completedTasks = [];
  String loadingMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final user = await _authService.currentUser();
    setState(() => _user = user);

    if (_user != null && _pendingTasks.isEmpty && _completedTasks.isEmpty) {
      _loadTasks();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTasks() async {
    try {
      setState(() => _isLoading = true);

      if (_user != null) {
        final querySnapshot =
            await tasksCollection.where('userId', isEqualTo: _user!.uid).get();

        _pendingTasks.clear();
        _completedTasks.clear();

        for (var doc in querySnapshot.docs) {
          final task = Task(
            title: doc['title'],
            completed: doc['completed'],
            id: doc.id,
            dateTime: (doc['dateTime'] as Timestamp).toDate(),
          );

          task.completed ? _completedTasks.add(task) : _pendingTasks.add(task);
        }

        setState(() => loadingMessage = '');
      }
    } catch (e) {
      setState(() => loadingMessage = 'Erro ao carregar as tarefas.');
      if (kDebugMode) print('Erro ao carregar as tarefas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildTaskItem(Task task, bool isPending) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: GestureDetector(
        onLongPress: () => _removeTask(task),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed
                    ? Theme.of(context).colorScheme.onSurface.withValues()
                    : null,
              ),
            ),
            subtitle: task.dateTime != null
                ? Text(
                    DateFormat('dd/MM/yyyy - HH:mm').format(task.dateTime!),
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSurface.withValues(),
                    ),
                  )
                : null,
            leading: isPending
                ? Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    value: task.completed,
                    onChanged: (value) => _updateTaskCompletion(task, value!),
                  )
                : Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeDetailsScreen(task: task),
                ),
              );
              if (result == true) await _loadTasks();
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _addTask() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null) return false;

    String newTaskTitle = '';
    DateTime? taskDateTime;

    return await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(appLocalizations.newTask),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: appLocalizations.inputTask,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => newTaskTitle = value,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today_rounded),
                    title: Text(taskDateTime != null
                        ? DateFormat('dd/MM/yyyy - HH:mm').format(taskDateTime!)
                        : appLocalizations.dateTime),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          // ignore: use_build_context_synchronously
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => taskDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              ));
                        }
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    if (newTaskTitle.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(appLocalizations.error),
                          content: Text(appLocalizations.inputTaskError),
                          actions: [
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(appLocalizations.ok),
                            ),
                          ],
                        ),
                      );
                    } else if (taskDateTime == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(appLocalizations.error),
                          content: Text(appLocalizations.inputDateError),
                          actions: [
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(appLocalizations.ok),
                            ),
                          ],
                        ),
                      );
                    } else {
                      await _createTask(newTaskTitle, taskDateTime!);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(appLocalizations.save),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<void> _createTask(String title, DateTime dateTime) async {
    if (_user == null) return;

    final taskRef = await tasksCollection.add({
      'title': title,
      'completed': false,
      'userId': _user!.uid,
      'dateTime': dateTime,
    });

    // Configuração de notificação
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      taskRef.id.hashCode,
      title,
      // ignore: use_build_context_synchronously
      '${AppLocalizations.of(context)!.notificationTask}: $title',
      tz.TZDateTime.from(dateTime, tz.getLocation('America/Manaus')),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'notification_id',
          'Tarefas',
          icon: '@drawable/ic_notification',
          channelDescription: 'Canal de notificações',
          importance: Importance.max,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    await _loadTasks();
  }

  Future<void> _updateTaskCompletion(Task task, bool completed) async {
    if (_user == null) return;

    try {
      await tasksCollection.doc(task.id).update({'completed': completed});
      setState(() {
        task.completed = completed;
        if (completed) {
          _pendingTasks.remove(task);
          _completedTasks.add(task);
        } else {
          _completedTasks.remove(task);
          _pendingTasks.add(task);
        }
      });
    } catch (e) {
      if (kDebugMode) print('Erro ao atualizar tarefa: $e');
    }
  }

  Future<void> _removeTask(Task task) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDelete),
            content: Text(AppLocalizations.of(context)!.confirmDeleteTask),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      try {
        await tasksCollection.doc(task.id).delete();
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
        await _loadTasks();
      } catch (e) {
        if (kDebugMode) print('Erro ao deletar tarefa: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.appName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                if (_pendingTasks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text(
                        appLocalizations.pendants.toUpperCase(),
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => buildTaskItem(_pendingTasks[index], true),
                    childCount: _pendingTasks.length,
                  ),
                ),
                if (_completedTasks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text(
                        appLocalizations.completed.toUpperCase(),
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => buildTaskItem(_completedTasks[index], false),
                    childCount: _completedTasks.length,
                  ),
                ),
                if (_pendingTasks.isEmpty && _completedTasks.isEmpty)
                  SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt_rounded,
                            size: 64, color: colors.onSurface.withValues()),
                        const SizedBox(height: 16),
                        Text(
                          appLocalizations.noTask,
                          style: TextStyle(
                            color: colors.onSurface.withValues(),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
