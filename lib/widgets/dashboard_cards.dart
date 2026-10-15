// ignore_for_file: deprecated_member_use
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tarefas/ai/assistant_service.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/tasks/tasks.dart';
import 'package:tarefas/widgets/orb_glass.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;
  final DateTime now;
  const GreetingHeader({super.key, required this.userName, required this.now});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateStr = _formatDate(context, now);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.greetingWithName(
                    AssistantService.greeting(now),
                    userName.isEmpty
                        ? AppLocalizations.of(context)!.you
                        : userName.split(' ').first,
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.55),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    final locale = AppLocalizations.of(context)!.localeName;
    return DateFormat('EEEE, d MMM', locale).format(d);
  }
}

class AiBriefingCard extends StatelessWidget {
  final DailyBriefing briefing;
  final VoidCallback? onFocusTap;
  const AiBriefingCard({super.key, required this.briefing, this.onFocusTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withOpacity(0.85),
            scheme.secondaryContainer.withOpacity(0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(
            scheme.brightness == Brightness.light ? 0.6 : 0.2,
          ),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.brightness == Brightness.light
                      ? Colors.white.withOpacity(0.85)
                      : scheme.surface.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      scheme.brightness == Brightness.light ? 0.6 : 0.15,
                    ),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: scheme.brightness == Brightness.light
                          ? scheme.primary
                          : scheme.primaryContainer.withOpacity(0.9) != scheme.primary
                              ? Colors.white
                              : scheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.assistantBadge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: scheme.brightness == Brightness.light
                            ? scheme.primary
                            : Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _ProgressRing(progress: briefing.progress),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            briefing.headline,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: scheme.brightness == Brightness.light
                  ? scheme.onPrimaryContainer
                  : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            briefing.suggestion,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: scheme.brightness == Brightness.light
                  ? scheme.onPrimaryContainer.withOpacity(0.8)
                  : scheme.onSurface.withOpacity(0.8),
            ),
          ),
          if (briefing.focusTask != null) ...[
            const SizedBox(height: 8),
            GlassPressable(
              onTap: onFocusTap,
              filter: OrbGlass.highBlur,
              hero: true,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: scheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.focusNow,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            briefing.focusTask!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = (progress * 100).round();
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress == 0 ? 0.02 : progress,
            strokeWidth: 4,
            backgroundColor: Colors.white.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
          Text(
            '$pct%',
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class StatsRow extends StatelessWidget {
  final ProductivityStats stats;
  final VoidCallback onFocusTap;
  const StatsRow({super.key, required this.stats, required this.onFocusTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.today_outlined,
              value: '${stats.todayDone}/${stats.todayTotal}',
              label: AppLocalizations.of(context)!.today,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              icon: Icons.warning_amber_rounded,
              value: '${stats.overdue}',
              label: AppLocalizations.of(context)!.overdue,
              color: stats.overdue > 0 ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: onFocusTap,
              borderRadius: BorderRadius.circular(16),
              child: _StatCard(
                icon: Icons.timer_outlined,
                value: AppLocalizations.of(context)!.focus,
                label: AppLocalizations.of(context)!.pomodoro,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withOpacity(0.65)
            : scheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight
              ? Colors.white.withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.03 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFilter {
  static const all = 0;
  static const today = 1;
  static const upcoming = 2;
  static const overdue = 3;
  static const done = 4;
}

List<Task> applyFilter(List<Task> tasks, int filter, [DateTime? now]) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  switch (filter) {
    case HomeFilter.today:
      return tasks
          .where(
            (t) =>
                !t.completed &&
                t.dateTime != null &&
                t.dateTime!.year == today.year &&
                t.dateTime!.month == today.month &&
                t.dateTime!.day == today.day,
          )
          .toList();
    case HomeFilter.upcoming:
      return tasks
          .where(
            (t) =>
                !t.completed && t.dateTime != null && t.dateTime!.isAfter(ref),
          )
          .toList();
    case HomeFilter.overdue:
      return tasks.where((t) => t.isOverdue).toList();
    case HomeFilter.done:
      return tasks.where((t) => t.completed).toList();
    default:
      return tasks.where((t) => !t.completed).toList();
  }
}
