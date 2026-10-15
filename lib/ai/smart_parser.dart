import 'package:tarefas/utils/app_strings.dart';

class ParsedTask {
  final String title;
  final DateTime? dateTime;
  final int priority;
  final String? project;
  final List<String> tags;

  const ParsedTask({
    required this.title,
    this.dateTime,
    this.priority = 4,
    this.project,
    this.tags = const [],
  });
}

class SmartParser {
  static final Map<String, int> _weekdays = {
    'domingo': 7,
    'segunda': 1,
    'terca': 2,
    'terça': 2,
    'quarta': 3,
    'quinta': 4,
    'sexta': 5,
    'sabado': 6,
    'sábado': 6,
    'sunday': 7,
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'lunes': 1,
    'martes': 2,
    'miércoles': 3,
    'miercoles': 3,
    'jueves': 4,
    'viernes': 5,
  };

  static ParsedTask parse(String input, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    var text = input.trim();
    if (text.isEmpty) {
      return const ParsedTask(title: '');
    }

    int priority = 4;
    String? project;
    final tags = <String>[];

    final projectReg = RegExp(r'#([\p{L}\p{N}_-]+)', unicode: true);
    final projectMatch = projectReg.firstMatch(text);
    if (projectMatch != null) {
      project = projectMatch.group(1)!.toLowerCase();
      text = text.replaceAll(projectReg, ' ');
    } else {
      final lowCheck = text.toLowerCase();
      if (RegExp(r'\b(trabalho|empresa|reuni[ãa]o|cliente|relat[óo]rio|apresenta[çc][ãa]o|projeto|work|meeting|client|report)\b').hasMatch(lowCheck)) {
        project = 'trabalho';
      } else if (RegExp(r'\b(casa|limpeza|faxina|conserto|reforma|compras?|mercado|feira|home|clean|grocery)\b').hasMatch(lowCheck)) {
        project = 'casa';
      } else if (RegExp(r'\b(estud(ar|o)?|prova|curso|aula|faculdade|livro|ler|artigo|study|exam|course|college)\b').hasMatch(lowCheck)) {
        project = 'estudos';
      } else if (RegExp(r'\b(sa[úu]de|m[ée]dico|dentista|exame|treino|academia|corrida|rem[ée]dio|health|doctor|gym|workout)\b').hasMatch(lowCheck)) {
        project = 'saude';
      } else if (RegExp(r'\b(conta|pagar|boleto|fatura|banco|dinheiro|investir|imposto|bill|pay|bank|money)\b').hasMatch(lowCheck)) {
        project = 'financas';
      }
    }

    final pExplicit = RegExp(r'!?\bp([1-4])\b', caseSensitive: false).firstMatch(text);
    if (pExplicit != null) {
      priority = int.parse(pExplicit.group(1)!);
      text = text.replaceAll(pExplicit.pattern, ' ');
      text = RegExp(r'!?\bp[1-4]\b', caseSensitive: false)
          .allMatches(input)
          .fold(text, (acc, _) => acc);
    }
    final lower = text.toLowerCase();
    if (lower.contains('urgent')) {
      priority = 1;
      text = text.replaceAll(RegExp(r'urgent[íi]ssimo|urgente|urgent', caseSensitive: false), ' ');
    } else if (lower.contains('alta prioridade') ||
        lower.contains('prioridade alta') ||
        lower.contains('high priority') ||
        lower.contains('prioridad alta') ||
        lower.contains('important')) {
      if (priority == 4) priority = 2;
      text = text.replaceAll(
          RegExp(r'alta prioridade|prioridade alta|high priority|prioridad alta|importante|important', caseSensitive: false), ' ');
    } else if (lower.contains('prioridade baixa') ||
        lower.contains('low priority') ||
        lower.contains('quando der') ||
        lower.contains('whenever')) {
      priority = 4;
      text = text.replaceAll(
          RegExp(r'prioridade baixa|low priority|quando der|whenever', caseSensitive: false), ' ');
    } else if (pExplicit == null) {
      if (RegExp(r'\b(pagar|conta|boleto|vencendo|hoje|agora|prazo|deadline|emerg[êe]ncia|hospital|m[ée]dico|bloqueio)\b').hasMatch(lower)) {
        priority = 1;
      } else if (RegExp(r'\b(reuni[ãa]o|entrevista|cliente|apresenta[çc][ãa]o|prova|exame|entrega|deploy|lan[çc]amento)\b').hasMatch(lower)) {
        priority = 2;
      } else if (RegExp(r'\b(estudar|treinar|compras|mercado|limpar|organizar|ligar|responder|email|ler)\b').hasMatch(lower)) {
        priority = 3;
      }
    }

    text = text.replaceAll(RegExp(r'!([1-4])'), ' ');

    int? hour;
    int minute = 0;
    final ampmReg = RegExp(
      r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b',
      caseSensitive: false,
    );
    final ampm = ampmReg.firstMatch(text);
    if (ampm != null) {
      var h = int.parse(ampm.group(1)!);
      final mi = int.tryParse(ampm.group(2) ?? '0') ?? 0;
      final isPm = ampm.group(3)!.toLowerCase() == 'pm';
      if (h >= 1 && h <= 12 && mi <= 59) {
        if (h == 12) h = 0;
        hour = isPm ? h + 12 : h;
        minute = mi;
        text = text.replaceAll(ampmReg, ' ');
      }
    }
    final timePatterns = [
      RegExp(r'(\d{1,2}):(\d{2})'),
      RegExp(r'(\d{1,2})h(\d{2})?'),
      RegExp(r'(?:às|as|at|a las|ao meio-dia|meio dia)\s*(\d{1,2})(?::(\d{2}))?'),
    ];
    for (final reg in hour != null ? <RegExp>[] : timePatterns) {
      final m = reg.firstMatch(text);
      if (m != null) {
        final h = int.tryParse(m.group(1) ?? '');
        final min = m.groupCount >= 2 ? int.tryParse(m.group(2) ?? '0') ?? 0 : 0;
        if (h != null && h >= 0 && h <= 23 && min >= 0 && min <= 59) {
          hour = h;
          minute = min;
          text = text.replaceAll(reg, ' ');
          break;
        }
      }
    }

    bool forceNight = RegExp(r'à noite|a noite|de noite|evening|tonight|at night|night', caseSensitive: false).hasMatch(text);
    bool forceMorning = RegExp(r'de manh[ãa]|cedo|morning', caseSensitive: false).hasMatch(text);
    bool forceAfternoon = RegExp(r'[àa] tarde|de tarde|depois do almo[çc]o|afternoon', caseSensitive: false).hasMatch(text);
    bool hasHoje = RegExp(r'\b(hoje|today|hoy|tonight)\b', caseSensitive: false).hasMatch(text);
    text = text.replaceAll(
        RegExp(r'à noite|a noite|de noite|tonight|at night|this evening|in the evening|evening|de manh[ãa]|this morning|in the morning|morning|cedo|[àa] tarde|de tarde|depois do almo[çc]o|this afternoon|in the afternoon|afternoon|night|hoje|today|hoy|agora|now|ahora',
            caseSensitive: false),
        ' ');

    DateTime? date;
    final low = text.toLowerCase();

    DateTime atTime(DateTime day) {
      if (hour != null) return DateTime(day.year, day.month, day.day, hour, minute);
      if (forceNight) return DateTime(day.year, day.month, day.day, 19, 0);
      if (forceAfternoon) return DateTime(day.year, day.month, day.day, 14, 0);
      if (forceMorning) return DateTime(day.year, day.month, day.day, 9, 0);
      return DateTime(day.year, day.month, day.day, 9, 0);
    }

    final dateReg = RegExp(r'(\d{1,2})/(\d{1,2})(?:/(\d{2,4}))?');
    final dateMatch = dateReg.firstMatch(text);
    if (dateMatch != null) {
      final d = int.tryParse(dateMatch.group(1)!);
      final mo = int.tryParse(dateMatch.group(2)!);
      var y = dateMatch.group(3) != null ? int.tryParse(dateMatch.group(3)!) : ref.year;
      if (y != null && y < 100) y += 2000;
      if (d != null && mo != null && y != null && mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
        var candidate = DateTime(y, mo, d, hour ?? 9, minute);
        if (candidate.isBefore(ref.subtract(const Duration(minutes: 1))) && dateMatch.group(3) == null) {
          candidate = DateTime(y + 1, mo, d, hour ?? 9, minute);
        }
        date = candidate;
        text = text.replaceAll(dateReg, ' ');
      }
    }

    final inHoursReg = RegExp(r'\b(?:em|in|en)\s*(\d{1,2})\s*(?:h|horas?|hours?|hrs?)\b', caseSensitive: false);
    final inHoursMatch = inHoursReg.firstMatch(text);
    if (inHoursMatch != null) {
      final addH = int.tryParse(inHoursMatch.group(1) ?? '0') ?? 0;
      if (addH > 0) {
        date = ref.add(Duration(hours: addH));
        text = text.replaceAll(inHoursReg, ' ');
      }
    }

    final inMinsReg = RegExp(r'\b(?:em|in|en)\s*(\d{1,2})\s*(?:min|minutos?|minutes?|mins?)\b', caseSensitive: false);
    final inMinsMatch = inMinsReg.firstMatch(text);
    if (inMinsMatch != null && date == null) {
      final addM = int.tryParse(inMinsMatch.group(1) ?? '0') ?? 0;
      if (addM > 0) {
        date = ref.add(Duration(minutes: addM));
        text = text.replaceAll(inMinsReg, ' ');
      }
    }

    if (date == null && RegExp(r'\b(fim de semana|final de semana|weekend|fin de semana)\b', caseSensitive: false).hasMatch(text)) {
      int daysToSaturday = (6 - ref.weekday) % 7;
      if (daysToSaturday <= 0) daysToSaturday += 7;
      date = atTime(ref.add(Duration(days: daysToSaturday)));
      text = text.replaceAll(RegExp(r'\b(no\s+|o\s+|next\s+|pr[óo]ximo\s+)?(fim de semana|final de semana|weekend|fin de semana)\b', caseSensitive: false), ' ');
    }

    if (date == null) {
      if (low.contains('depois de amanh') ||
          low.contains('depois de amanha') ||
          low.contains('day after tomorrow') ||
          low.contains('pasado mañana')) {
        final day = ref.add(const Duration(days: 2));
        date = atTime(day);
        text = text.replaceAll(RegExp(r'depois de amanh[ãa]|day after tomorrow|pasado mañana', caseSensitive: false), ' ');
      } else if (low.contains('amanh') || low.contains('tomorrow') || low.contains('mañana')) {
        final day = ref.add(const Duration(days: 1));
        date = atTime(day);
        text = text.replaceAll(RegExp(r'amanh[ãa]|tomorrow|mañana', caseSensitive: false), ' ');
      } else {

        for (final entry in _weekdays.entries) {
          if (low.contains(entry.key)) {
            final target = entry.value;
            var diff = target - ref.weekday;
            if (diff <= 0) diff += 7;

            final day = ref.add(Duration(days: diff));
            date = atTime(day);
            text = text.replaceAll(RegExp(entry.key, caseSensitive: false), ' ');

            text = text.replaceAll(
                RegExp(r'-feira|feira|pr[óo]xima|que vem|next', caseSensitive: false), ' ');
            break;
          }
        }
      }
    }

    if (date == null && hour != null) {
      var candidate = DateTime(ref.year, ref.month, ref.day, hour, minute);
      if (candidate.isBefore(ref)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      date = candidate;
    }

    if (date == null && (hasHoje || forceNight || forceMorning || forceAfternoon)) {
      date = atTime(DateTime(ref.year, ref.month, ref.day));
      if (date.isBefore(ref.subtract(const Duration(hours: 2))) && !hasHoje) {

        final tomorrow = ref.add(const Duration(days: 1));
        date = atTime(DateTime(tomorrow.year, tomorrow.month, tomorrow.day));
      }
    }

    var title = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^\bdia\b\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^[,\-\s]+|[,\-\s]+$'), '')
        .trim();

    if (title.isNotEmpty) {
      title = title[0].toUpperCase() + title.substring(1);
    }

    return ParsedTask(
      title: title,
      dateTime: date,
      priority: priority.clamp(1, 4),
      project: project,
      tags: tags,
    );
  }

  static String priorityLabel(int p) {
    switch (p) {
      case 1:
        return S.current.priorityUrgent;
      case 2:
        return S.current.priorityHigh;
      case 3:
        return S.current.priorityMedium;
      default:
        return S.current.priorityNormal;
    }
  }
}
