// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/theme/theme.dart';
import 'package:tarefas/widgets/orb_glass.dart';
import 'package:tarefas/widgets/settings_group.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(
          l10n.personalization,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 40),
        children: [
          // Theme Mode Selection
          SettingsGroup(
            title: l10n.theme,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.displayMode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ThemeModeCard(
                        mode: ThemeModeType.light,
                        label: l10n.lightMode,
                        icon: Icons.light_mode_rounded,
                        isSelected: themeModel.themeMode == ThemeModeType.light,
                        accentColor: themeModel.primaryColor,
                        onTap: () =>
                            themeModel.changeThemeMode(ThemeModeType.light),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ThemeModeCard(
                        mode: ThemeModeType.dark,
                        label: l10n.darkMode,
                        icon: Icons.dark_mode_rounded,
                        isSelected: themeModel.themeMode == ThemeModeType.dark,
                        accentColor: themeModel.primaryColor,
                        onTap: () =>
                            themeModel.changeThemeMode(ThemeModeType.dark),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ThemeModeCard(
                        mode: ThemeModeType.system,
                        label: l10n.systemMode,
                        icon: Icons.brightness_auto_rounded,
                        isSelected:
                            themeModel.themeMode == ThemeModeType.system,
                        accentColor: themeModel.primaryColor,
                        onTap: () =>
                            themeModel.changeThemeMode(ThemeModeType.system),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Accent Color Selection
          SettingsGroup(
            title: l10n.color,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.color_lens_outlined,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.accentColor,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - (12 * 3)) / 4;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 14,
                      alignment: WrapAlignment.start,
                      children: themeModel.availableAccentColors.map((color) {
                        final selected = themeModel.primaryColor == color;
                        return SizedBox(
                          width: itemWidth,
                          child: _ColorSwatchButton(
                            color: color,
                            isSelected: selected,
                            onTap: () => themeModel.setPrimaryColor(color),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Visual Illustrated Theme Mode Card
class _ThemeModeCard extends StatelessWidget {
  final ThemeModeType mode;
  final String label;
  final IconData icon;
  final bool isSelected;
  final MaterialColor accentColor;
  final VoidCallback onTap;

  const _ThemeModeCard({
    required this.mode,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isSelected
        ? accentColor.withOpacity(isDark ? 0.20 : 0.12)
        : (isDark
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.35)
              : theme.colorScheme.surface.withOpacity(0.60));

    final borderColor = isSelected
        ? accentColor
        : (isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Mini mockup illustration preview usando as cores reais do app
            _buildMiniMockup(context, mode),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? accentColor
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? accentColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMockup(BuildContext context, ThemeModeType mode) {
    const mockupHeight = 44.0;
    const mockupWidth = double.infinity;

    Widget buildSide({required bool dark}) {
      final scheme = ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: dark ? Brightness.dark : Brightness.light,
      );
      final bg = scheme.surface;
      final border = dark
          ? Colors.white.withOpacity(0.10)
          : Colors.black.withOpacity(0.08);
      final barColor = scheme.onSurface.withOpacity(dark ? 0.25 : 0.15);
      final accent = scheme.primary;

      return Container(
        height: mockupHeight,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 0.8),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 4,
              width: 24,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: 4,
              width: 16,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      );
    }

    if (mode == ThemeModeType.light) {
      return buildSide(dark: false);
    } else if (mode == ThemeModeType.dark) {
      return buildSide(dark: true);
    } else {
      // Split / System mode
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: mockupHeight,
          width: mockupWidth,
          child: Row(
            children: [
              Expanded(child: buildSide(dark: false)),
              Container(width: 1, color: Colors.grey.withOpacity(0.3)),
              Expanded(child: buildSide(dark: true)),
            ],
          ),
        ),
      );
    }
  }
}

/// Refined Color Swatch Button with scale feedback and check ring
class _ColorSwatchButton extends StatelessWidget {
  final MaterialColor color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatchButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.shade400, color.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: isSelected ? 2.5 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isSelected ? 0.55 : 0.25),
                    blurRadius: isSelected ? 12 : 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
