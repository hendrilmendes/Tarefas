// ignore_for_file: deprecated_member_use
import 'package:tarefas/utils/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/ai/assistant_service.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/screens/home/home_details.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/widgets/orb_glass.dart';
import 'package:tarefas/widgets/task_tile.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  Map<String, List<Task>> _group(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final map = <String, List<Task>>{};
    final overdue = tasks.where((t) => t.isOverdue).toList();
    final l10n = S.current;
    final dfmt = DateFormat.Md(l10n.localeName);
    if (overdue.isNotEmpty) map[l10n.overdue] = overdue;

    for (var i = 0; i < 14; i++) {
      final day = today.add(Duration(days: i));
      final items = tasks
          .where(
            (t) =>
                !t.completed &&
                t.dateTime != null &&
                t.dateTime!.year == day.year &&
                t.dateTime!.month == day.month &&
                t.dateTime!.day == day.day,
          )
          .toList();
      if (items.isEmpty) continue;
      items.sort((a, b) => (a.dateTime ?? now).compareTo(b.dateTime ?? now));
      final label = i == 0
          ? '${l10n.today} • ${dfmt.format(day)}'
          : i == 1
          ? '${l10n.tomorrow} • ${dfmt.format(day)}'
          : '${DateFormat.E(l10n.localeName).format(day)} • ${dfmt.format(day)}';
      map[label] = items;
    }

    final noDate = tasks
        .where((t) => !t.completed && t.dateTime == null)
        .toList();
    if (noDate.isNotEmpty) map[l10n.noDateGroup] = noDate;
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: GlassAppBar(
        title: Text(AppLocalizations.of(context)!.agenda, style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: StreamBuilder<QuerySnapshot>(
          stream: uid != null
              ? tasksCollection.where('userId', isEqualTo: uid).snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final all = (snapshot.data?.docs ?? []).map(Task.fromDoc).toList();
            final groups = _group(all);
            final openCount = all.where((t) => !t.completed).length;
            final tip = AssistantService.bestSlotToday(all);
            if (groups.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          size: 52,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.agendaFreeTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.agendaFreeBody(tip),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.65),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 110, top: 12),
              children: [

                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer.withOpacity(0.9),
                        scheme.secondaryContainer.withOpacity(0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        scheme.brightness == Brightness.light ? 0.6 : 0.2,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.event_available_outlined,
                          color: scheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.agendaCount(openCount),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tip,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: scheme.onPrimaryContainer.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ...groups.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      ...entry.value.map(
                        (t) => TaskTile(
                          task: t,
                          onToggle: () => tasksCollection.doc(t.id).update({
                            'completed': !t.completed,
                          }),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomeDetailsScreen(task: t),
                            ),
                          ),
                          onDelete: () => tasksCollection.doc(t.id).delete(),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
