import 'package:tarefas/utils/app_strings.dart';

import 'package:tarefas/tasks/tasks.dart';

class DailyBriefing {
  final String greeting;
  final String headline;
  final String suggestion;
  final Task? focusTask;
  final double progress;
  final int overdue;
  final int today;
  final int done;

  const DailyBriefing({
    required this.greeting,
    required this.headline,
    required this.suggestion,
    this.focusTask,
    required this.progress,
    required this.overdue,
    required this.today,
    required this.done,
  });
}

class ProductivityStats {
  final int total;
  final int done;
  final int pending;
  final int overdue;
  final double rate;
  final int todayTotal;
  final int todayDone;

  const ProductivityStats({
    required this.total,
    required this.done,
    required this.pending,
    required this.overdue,
    required this.rate,
    required this.todayTotal,
    required this.todayDone,
  });
}

class AssistantService {
  static String greeting([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 6) return S.current.greetingNight;
    if (h < 12) return S.current.greetingMorning;
    if (h < 18) return S.current.greetingAfternoon;
    return S.current.greetingEvening;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int score(Task t, DateTime now) {
    int s = 0;
    if (t.dateTime != null) {
      final diff = t.dateTime!.difference(now).inMinutes;
      if (diff < 0) {
        s -= 10000;
        s += (diff ~/ 60);
      } else if (diff < 60 * 5) {
        s -= 3000;
      } else if (_isSameDay(t.dateTime!, now)) {
        s -= 1500;
      } else if (diff < 60 * 24 * 2) {
        s -= 500;
      }
    }
    s += (t.priority - 1) * -400;

    s -= (5 - t.priority) * 120;
    return s;
  }

  static Task? suggestNext(List<Task> pending, [DateTime? now]) {
    final ref = now ?? DateTime.now();
    final open = pending.where((t) => !t.completed).toList();
    if (open.isEmpty) return null;
    open.sort((a, b) => score(a, ref).compareTo(score(b, ref)));
    return open.first;
  }

  static DailyBriefing briefing(List<Task> all, String userName, [DateTime? now]) {
    final ref = now ?? DateTime.now();
    final open = all.where((t) => !t.completed).toList();
    final done = all.where((t) => t.completed).length;
    final overdue = open.where((t) => t.isOverdue).length;
    final today = open.where((t) => t.dateTime != null && _isSameDay(t.dateTime!, ref)).length;
    final progress = all.isEmpty ? 0.0 : done / all.length;

    final focus = suggestNext(open, ref);

    final l10n = S.current;
    String headline;
    if (all.isEmpty) {
      headline = l10n.briefingEmpty;
    } else if (overdue > 0 && today > 0) {
      headline = l10n.briefingOverdueToday(overdue, today);
    } else if (overdue > 0) {
      headline = l10n.briefingOverdue(overdue);
    } else if (today > 0) {
      headline = l10n.briefingToday(today);
    } else if (open.isNotEmpty) {
      headline = l10n.briefingPending(open.length);
    } else {
      headline = l10n.briefingAllDone;
    }

    String suggestion;
    if (focus != null) {
      final when = _describeWhen(focus, ref);
      suggestion = l10n.suggestionFocus(focus.title, when);
    } else {
      suggestion = l10n.suggestionCreate;
    }

    return DailyBriefing(
      greeting: l10n.greetingWithName(greeting(ref), userName.isEmpty ? l10n.you : userName),
      headline: headline,
      suggestion: suggestion,
      focusTask: focus,
      progress: progress.clamp(0.0, 1.0),
      overdue: overdue,
      today: today,
      done: done,
    );
  }

  static String _describeWhen(Task t, DateTime ref) {
    final l10n = S.current;
    if (t.dateTime == null) return l10n.whenNoTime;
    if (t.isOverdue) return l10n.whenOverdue;
    if (_isSameDay(t.dateTime!, ref)) {
      final h = t.dateTime!.hour.toString().padLeft(2, '0');
      final m = t.dateTime!.minute.toString().padLeft(2, '0');
      return l10n.whenToday('$h:$m');
    }
    final diff = t.dateTime!.difference(ref).inDays;
    if (diff == 1) return l10n.whenTomorrow;
    return l10n.whenInDays(diff);
  }

  static ProductivityStats stats(List<Task> all, [DateTime? now]) {
    final ref = now ?? DateTime.now();
    final done = all.where((t) => t.completed).length;
    final pending = all.length - done;
    final overdue = all.where((t) => t.isOverdue).length;
    final todayList = all.where((t) => t.dateTime != null && _isSameDay(t.dateTime!, ref)).toList();
    final todayDone = todayList.where((t) => t.completed).length;
    return ProductivityStats(
      total: all.length,
      done: done,
      pending: pending,
      overdue: overdue,
      rate: all.isEmpty ? 0 : done / all.length,
      todayTotal: todayList.length,
      todayDone: todayDone,
    );
  }

  static List<String> breakdown(String title) {
    final t = title.toLowerCase();
    final l10n = S.current;
    bool has(List<String> keys) => keys.any(t.contains);
    String raw;
    if (has(['compr', 'mercado', 'feira', 'supermercado', 'grocery', 'buy', 'shop'])) {
      raw = l10n.stepsShopping;
    } else if (has(['reuni', 'meeting', 'alinhar', 'call', 'sync', 'alinhamento'])) {
      raw = l10n.stepsMeeting;
    } else if (has(['program', 'código', 'codigo', 'bug', 'fix', 'deploy', 'pr', 'feature', 'dev', 'code', 'develop'])) {
      raw = l10n.stepsCoding;
    } else if (has(['finan', 'invest', 'extrato', 'imposto', 'orçamento', 'orcamento', 'budget', 'finance', 'money'])) {
      raw = l10n.stepsFinance;
    } else if (has(['médic', 'medic', 'consulta', 'exame', 'dentista', 'remédio', 'remedio', 'doctor', 'appointment', 'salud', 'saude', 'saúde'])) {
      raw = l10n.stepsHealth;
    } else if (has(['viagem', 'trip', 'travel', 'viaje'])) {
      raw = l10n.stepsTravel;
    } else if (has(['estud', 'prova', 'curso', 'study', 'exam', 'course', 'estudi', 'examen', 'curso'])) {
      raw = l10n.stepsStudy;
    } else if (has(['limp', 'organiza', 'casa', 'clean', 'organiz', 'house', 'limpi'])) {
      raw = l10n.stepsClean;
    } else if (has(['projeto', 'relat', 'apresenta', 'project', 'report', 'present', 'proyecto', 'informe'])) {
      raw = l10n.stepsProject;
    } else if (has(['exerc', 'academia', 'correr', 'caminh', 'gym', 'workout', 'run', 'walk', 'gimnasio', 'correr'])) {
      raw = l10n.stepsWorkout;
    } else if (has(['conta', 'pagar', 'boleto', 'bill', 'pay', 'invoice', 'factura'])) {
      raw = l10n.stepsBill;
    } else {
      raw = l10n.stepsGeneric;
    }
    return raw.split('|');
  }

  static String bestSlotToday(List<Task> all, [DateTime? now]) {
    final ref = now ?? DateTime.now();
    final busyHours = all
        .where((t) => t.dateTime != null && _isSameDay(t.dateTime!, ref) && !t.completed)
        .map((t) => t.dateTime!.hour)
        .toSet();
    const candidates = [9, 11, 14, 16, 19];
    for (final h in candidates) {
      if (!busyHours.contains(h) && h > ref.hour) {
        return S.current.slotToday('${h.toString().padLeft(2, '0')}:00');
      }
    }
    return S.current.slotTomorrow;
  }
}
