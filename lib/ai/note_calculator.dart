class NoteCalculation {
  final double total;
  final int count;
  final List<double> values;
  final String? detectedCurrency;

  const NoteCalculation({
    required this.total,
    required this.count,
    required this.values,
    this.detectedCurrency,
  });

  bool get hasValues => count > 0;
  bool get hasMultiple => count > 1;

  String formattedTotal({String defaultSymbol = 'R\$'}) {
    final symbol = detectedCurrency ?? defaultSymbol;
    return '$symbol ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class NoteCalculator {
  static final RegExp _currencyRegex = RegExp(
    r'(?:(R\$|\$|€|£)\s*)?(\d{1,3}(?:\.\d{3})*(?:,\d{1,2})|\d+(?:[.,]\d{1,2})?)',
    caseSensitive: false,
  );

  static NoteCalculation calculate(String text) {
    if (text.trim().isEmpty) {
      return const NoteCalculation(total: 0, count: 0, values: []);
    }

    final lines = text.split('\n');
    final values = <double>[];
    String? detectedCurrency;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final matches = _currencyRegex.allMatches(trimmed);
      for (final m in matches) {
        final symbol = m.group(1);
        final rawNum = m.group(2);
        if (rawNum == null) continue;

        if (symbol != null && symbol.isNotEmpty) {
          detectedCurrency ??= symbol.toUpperCase();
        }

        String normalized = rawNum;
        if (normalized.contains('.') && normalized.contains(',')) {
          normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
        } else if (normalized.contains(',')) {
          normalized = normalized.replaceAll(',', '.');
        }

        final parsed = double.tryParse(normalized);
        if (parsed != null && parsed > 0) {
          final isBareInteger = !rawNum.contains('.') && !rawNum.contains(',');
          if (isBareInteger && symbol == null) {
            final matchStart = m.start;
            final isAtStartOfLine = matchStart == 0 || trimmed.substring(0, matchStart).trim().isEmpty;
            final followsListItem = isAtStartOfLine && (trimmed.startsWith('$rawNum.') || trimmed.startsWith('$rawNum -') || trimmed.startsWith('$rawNum)'));
            if (followsListItem) {
              continue;
            }
          }
          values.add(parsed);
        }
      }
    }

    final total = values.fold<double>(0.0, (sum, item) => sum + item);
    return NoteCalculation(
      total: total,
      count: values.length,
      values: values,
      detectedCurrency: detectedCurrency,
    );
  }
}
