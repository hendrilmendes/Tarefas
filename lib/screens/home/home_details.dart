// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarefas/tasks/tasks.dart';
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
  int _selectedAction = 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);
    _selectedDateTime = widget.task.dateTime;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onActionSelected(int index) {
    setState(() {
      _selectedAction = index;
    });

    switch (index) {
      case 0:
        _delete();
        break;
      case 1:
        _saveTask();
        break;
      case 2:
        _shareTask();
        break;
    }
  }

  void _saveTask() {
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
  }

  Future<void> _delete() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 32,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        appLocalizations.confirmDelete,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appLocalizations.confirmDeleteTask,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(appLocalizations.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onError,
                              ),
                              child: Text(appLocalizations.delete),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await tasksCollection.doc(widget.task.id).delete();

      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancel(widget.task.id.hashCode);

      if (kDebugMode) {
        print('Tarefa removida do Firestore: ${widget.task.id}');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao apagar tarefa: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao apagar tarefa: $e')));
      }
    }
  }

  void _shareTask() {
    final formattedDate = _selectedDateTime != null
        ? DateFormat('dd/MM/yyyy • HH:mm').format(_selectedDateTime!)
        : AppLocalizations.of(context)!.noDate;

    SharePlus.instance.share(
      ShareParams(
        text:
            '${AppLocalizations.of(context)!.taskTitle}: ${widget.task.title}\n'
            '${AppLocalizations.of(context)!.dateTitle}: $formattedDate',
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
        await tasksCollection.doc(widget.task.id).update({
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
          AppLocalizations.of(context)!.notificationTask,
          tz.TZDateTime.from(updatedTask.dateTime!, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating task: $e');
        }
      }
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AppBar(
              backgroundColor: colors.surface.withOpacity(0.8),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Text(
                AppLocalizations.of(context)!.taskDetails,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: colors.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surface, colors.surface.withOpacity(0.95)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),

                // Task Title Section
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    AppLocalizations.of(context)!.inputTask,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                          height: 1.4,
                        ),
                        maxLines: null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          hintText: AppLocalizations.of(context)!.inputTask,
                          hintStyle: TextStyle(
                            color: colors.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Date Time Section
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    AppLocalizations.of(context)!.dateTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDateTime ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              if (!mounted) return;
                              final selectedTime = await showTimePicker(
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
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.schedule_outlined,
                                    size: 20,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _selectedDateTime != null
                                        ? DateFormat(
                                            'dd/MM/yyyy • HH:mm',
                                          ).format(_selectedDateTime!)
                                        : AppLocalizations.of(
                                            context,
                                          )!.dateTime,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedDateTime != null
                                          ? colors.onSurface
                                          : colors.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: colors.onSurface.withOpacity(0.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        selectedIndex: _selectedAction,
        onItemSelected: _onActionSelected,
        items: [
          GlassNavBarItem(
            icon: CupertinoIcons.delete,
            label: AppLocalizations.of(context)!.delete,
          ),
          GlassNavBarItem(
            icon: CupertinoIcons.checkmark_alt_circle,
            label: AppLocalizations.of(context)!.save,
          ),
          GlassNavBarItem(
            icon: CupertinoIcons.share,
            label: AppLocalizations.of(context)!.share,
          ),
        ],
      ),
    );
  }
}

class GlassNavBarItem {
  final IconData icon;
  final String label;

  GlassNavBarItem({required this.icon, required this.label});
}

class GlassNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<GlassNavBarItem> items;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar> {
  final Duration _animationDuration = const Duration(milliseconds: 200);
  final Curve _animationCurve = Curves.easeInOutQuart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.secondary;
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.items.asMap().entries.map((entry) {
                int index = entry.key;
                GlassNavBarItem item = entry.value;
                bool isSelected = index == widget.selectedIndex;

                return GestureDetector(
                  onTap: () => widget.onItemSelected(index),
                  child: AnimatedContainer(
                    duration: _animationDuration,
                    curve: _animationCurve,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 20.0 : 12.0,
                      vertical: 8.0,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: selectedColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100.0),
                            boxShadow: [
                              BoxShadow(
                                color: selectedColor.withOpacity(0.1),
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? selectedColor : unselectedColor,
                          size: isSelected ? 28.0 : 24.0,
                        ),
                        AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: _animationDuration,
                          curve: _animationCurve,
                          child: AnimatedSize(
                            duration: _animationDuration,
                            curve: _animationCurve,
                            alignment: Alignment.center,
                            child: isSelected
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        color: selectedColor,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
