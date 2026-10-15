// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:tarefas/utils/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarefas/ai/assistant_service.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/widgets/action_fab.dart';
import 'package:tarefas/widgets/orb_glass.dart';
import 'package:tarefas/widgets/settings_group.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeDetailsScreen extends StatefulWidget {
  final Task task;

  const HomeDetailsScreen({super.key, required this.task});

  @override
  State<HomeDetailsScreen> createState() => _HomeDetailsScreenState();
}

class _HomeDetailsScreenState extends State<HomeDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _projectController;
  late DateTime? _selectedDateTime;
  late int _priority;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _projectController = TextEditingController(text: widget.task.project ?? '');
    _selectedDateTime = widget.task.dateTime;
    _priority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null || !mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (!mounted) return;
    setState(() {
      if (selectedTime != null) {
        _selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      } else {
        _selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 9, 0);
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.inputTaskError)));
      return;
    }
    setState(() => _saving = true);
    try {
      final projectText = _projectController.text.trim().replaceAll('#', '');
      await tasksCollection.doc(widget.task.id).update({
        'title': title,
        'completed': widget.task.completed,
        'dateTime': _selectedDateTime,
        'priority': _priority,
        if (projectText.isNotEmpty) 'project': projectText,
      });

      if (_selectedDateTime != null && _selectedDateTime!.isAfter(DateTime.now())) {
        final details = NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            S.current.notificationChannelName,
            channelDescription: S.current.notificationChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        );
        await FlutterLocalNotificationsPlugin().zonedSchedule(
          id: widget.task.id.hashCode,
          title: title,
          body: l10n.notificationTask,
          scheduledDate: tz.TZDateTime.from(_selectedDateTime!, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) print('Error updating task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.current.errorSaving('$e'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await confirmDeleteDialog(
      context,
      title: l10n.confirmDelete,
      message: l10n.confirmDeleteTask,
    );
    if (!confirmed) return;
    try {
      await FlutterLocalNotificationsPlugin().cancel(id: widget.task.id.hashCode);
      await tasksCollection.doc(widget.task.id).delete();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.current.errorDeleting('$e'))));
      }
    }
  }

  void _share() {
    final l10n = AppLocalizations.of(context)!;
    final date = _selectedDateTime != null
        ? DateFormat.yMd(l10n.localeName).add_Hm().format(_selectedDateTime!)
        : l10n.noDate;
    SharePlus.instance.share(ShareParams(text: '${l10n.taskTitle}: ${_titleController.text}\n${l10n.dateTitle}: $date'));
  }

  void _toggleDone() async {
    try {
      await tasksCollection.doc(widget.task.id).update({'completed': !widget.task.completed});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.current.updateTaskFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final steps = widget.task.subtasks.isNotEmpty
        ? widget.task.subtasks
        : AssistantService.breakdown(_titleController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskDetails, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [

          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
            ),
            color: widget.task.completed
                ? scheme.primaryContainer.withOpacity(0.5)
                : scheme.surfaceContainerHighest.withOpacity(0.45),
            child: SwitchListTile(
              title: Text(
                widget.task.completed ? l10n.completedLabel : l10n.markAsCompleted,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              secondary: Icon(
                widget.task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: scheme.primary,
              ),
              value: widget.task.completed,
              onChanged: (_) => _toggleDone(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 16),
          _Label(l10n.inputTask),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.inputTask,
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(18),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _Label(l10n.dateTime),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
            ),
            color: scheme.surfaceContainerHighest.withOpacity(0.45),
            child: ListTile(
              onTap: _pickDateTime,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.schedule_outlined, color: scheme.primary, size: 20),
              ),
              title: Text(
                _selectedDateTime != null
                    ? DateFormat.yMd(l10n.localeName).add_Hm().format(_selectedDateTime!)
                    : l10n.dateTime,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              trailing: _selectedDateTime != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _selectedDateTime = null),
                    )
                  : const Icon(Icons.chevron_right, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          _Label(l10n.priority),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('P1')),
              ButtonSegment(value: 2, label: Text('P2')),
              ButtonSegment(value: 3, label: Text('P3')),
              ButtonSegment(value: 4, label: Text('P4')),
            ],
            selected: {_priority},
            onSelectionChanged: (s) => setState(() => _priority = s.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16),
          _Label(l10n.projectOptional),
          const SizedBox(height: 8),
          TextField(
            controller: _projectController,
            decoration: InputDecoration(
              hintText: l10n.projectHint,
              prefixIcon: const Icon(Icons.tag, size: 20),
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
          const SizedBox(height: 16),
          _Label(l10n.aiSuggestedSteps),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: OrbGlass(
              filter: OrbGlass.highBlur,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: orbGlassDecoration(Theme.of(context),
                    borderRadius: BorderRadius.circular(24), hero: true),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    for (var i = 0; i < steps.length; i++)
                      ListTile(
                        dense: true,
                        leading: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text('${i + 1}',
                              style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary, fontSize: 13)),
                        ),
                        title: Text(steps[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: InsetFabLocation.aboveSystemBar(context),
      floatingActionButton: ActionFab(
        busy: _saving,
        primary: FabAction(
          icon: Icons.check,
          label: l10n.save,
          onPressed: _save,
        ),
        secondary: [
          FabAction(
            icon: Icons.share_outlined,
            label: l10n.share,
            onPressed: _share,
          ),
          FabAction(
            icon: Icons.delete_outline,
            label: l10n.delete,
            onPressed: _delete,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
