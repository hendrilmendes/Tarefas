// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/widgets/orb_glass.dart';

class PriorityStyle {
  static Color color(BuildContext context, int p) {
    final scheme = Theme.of(context).colorScheme;
    switch (p) {
      case 1:
        return scheme.error;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return scheme.outline;
    }
  }

  static String label(int p) {
    switch (p) {
      case 1:
        return 'P1';
      case 2:
        return 'P2';
      case 3:
        return 'P3';
      default:
        return 'P4';
    }
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  final bool featured;
  final bool reduceEffects;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.featured = false,
    this.reduceEffects = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pColor = PriorityStyle.color(context, task.priority);
    final dateStr = task.dateTime != null
        ? DateFormat.Md(AppLocalizations.of(context)!.localeName).add_Hm().format(task.dateTime!)
        : null;

    Widget content = _TileBody(
      task: task,
      pColor: pColor,
      dateStr: dateStr,
      onToggle: onToggle,
      onTap: onTap,
    );

    Widget card;
    if (featured) {

      card = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: OrbGlass.autoReduce(
          reduce: reduceEffects,
          filter: OrbGlass.highBlur,
          borderRadius: BorderRadius.circular(20),
          fallbackColor: scheme.surfaceContainerHighest.withOpacity(0.85),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(scheme.brightness == Brightness.light ? 0.22 : 0.10),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: content,
          ),
        ),
      );
    } else {
      card = Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: scheme.brightness == Brightness.light
              ? scheme.surface.withOpacity(0.70)
              : scheme.surfaceContainerHighest.withOpacity(0.35),
          border: Border.all(
            color: scheme.brightness == Brightness.light
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: content,
      );
    }

    return Dismissible(
      key: ValueKey(task.id ?? task.title),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: scheme.error.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onToggle();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: card,
    );
  }
}

class _TileBody extends StatelessWidget {
  final Task task;
  final Color pColor;
  final String? dateStr;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _TileBody({
    required this.task,
    required this.pColor,
    required this.dateStr,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: task.completed ? scheme.outline : pColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: pColor, width: 2),
                      color: task.completed ? pColor : Colors.transparent,
                    ),
                    child: task.completed
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                      color: task.completed
                          ? scheme.onSurface.withOpacity(0.55)
                          : scheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (dateStr != null)
                        _Chip(
                          icon: task.isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
                          label: dateStr!,
                          color: task.isOverdue
                              ? scheme.error
                              : scheme.onSurface.withOpacity(0.65),
                          bg: task.isOverdue
                              ? scheme.error.withOpacity(0.12)
                              : scheme.surfaceContainerHighest.withOpacity(0.9),
                        ),
                      if (task.priority != 4)
                        _Chip(
                          icon: Icons.flag_outlined,
                          label: PriorityStyle.label(task.priority),
                          color: pColor,
                          bg: pColor.withOpacity(0.12),
                        ),
                      if (task.project != null && task.project!.isNotEmpty)
                        _Chip(
                          icon: Icons.tag,
                          label: '#${task.project!}',
                          color: scheme.primary,
                          bg: scheme.primary.withOpacity(0.12),
                        ),
                      if (task.subtasks.isNotEmpty)
                        _Chip(
                          icon: Icons.list,
                          label: AppLocalizations.of(context)!.steps(task.subtasks.length),
                          color: scheme.secondary,
                          bg: scheme.secondary.withOpacity(0.12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _Chip({required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
