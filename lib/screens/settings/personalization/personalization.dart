// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/l10n/app_localizations.dart';
import 'package:tarefas/theme/theme.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  bool _isAndroid12 = false;

  @override
  void initState() {
    super.initState();
    _checkAndroidVersion();
  }

  Future<void> _checkAndroidVersion() async {
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        if (mounted) {
          setState(() {
            _isAndroid12 = androidInfo.version.sdkInt >= 31;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isAndroid12 = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    final List<MaterialColor> accentColors = [
      Colors.amber,
      Colors.blue,
      Colors.brown,
      Colors.green,
      Colors.grey,
      Colors.indigo,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.yellow,
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      extendBodyBehindAppBar: true,
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
                localizations.personalization,
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, localizations.theme),

                  _buildGlassmorphismCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.paintbrush_fill,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                localizations.displayMode,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child:
                              CupertinoSlidingSegmentedControl<ThemeModeType>(
                                backgroundColor: colors.surface.withOpacity(
                                  0.4,
                                ), // Cor de fundo mais integrada
                                thumbColor: colors.primary,
                                groupValue: themeModel.themeMode,
                                onValueChanged: (ThemeModeType? newValue) {
                                  if (newValue != null) {
                                    themeModel.changeThemeMode(newValue);
                                  }
                                },
                                children: {
                                  ThemeModeType.light: _buildSegment(
                                    context,
                                    localizations.lightMode,
                                    CupertinoIcons.sun_max_fill,
                                    themeModel.themeMode == ThemeModeType.light,
                                  ),
                                  ThemeModeType.dark: _buildSegment(
                                    context,
                                    localizations.darkMode,
                                    CupertinoIcons.moon_fill,
                                    themeModel.themeMode == ThemeModeType.dark,
                                  ),
                                  ThemeModeType.system: _buildSegment(
                                    context,
                                    localizations.systemMode,
                                    CupertinoIcons.device_phone_portrait,
                                    themeModel.themeMode ==
                                        ThemeModeType.system,
                                  ),
                                },
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, localizations.color),
                  _buildGlassmorphismCard(
                    context,
                    child: Column(
                      children: [
                        if (_isAndroid12)
                          SwitchListTile(
                            title: Text(
                              localizations.dynamicColors,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              localizations.dynamicColorsSub,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurface.withOpacity(0.7),
                              ),
                            ),
                            value: themeModel.isDynamicColorsEnabled,
                            onChanged: (value) {
                              themeModel.toggleDynamicColors();
                            },
                            secondary: Icon(
                              CupertinoIcons.color_filter_fill,
                              color: colors.primary,
                            ),
                            activeColor: colors.primary,
                            contentPadding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              12,
                              8,
                            ),
                          ),
                        if (_isAndroid12)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.eyedropper_full,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                localizations.accentColor,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: accentColors.map((color) {
                              final bool isSelected =
                                  (!themeModel.isDynamicColorsEnabled &&
                                  themeModel.primaryColor == color);

                              return GestureDetector(
                                onTap: themeModel.isDynamicColorsEnabled
                                    ? null
                                    : () => themeModel.setPrimaryColor(color),
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: themeModel.isDynamicColorsEnabled
                                      ? 0.6
                                      : 1.0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: colors.onSurface,
                                              width: 3,
                                            )
                                          : Border.all(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: -2,
                                        ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            CupertinoIcons.checkmark_alt,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (themeModel.isDynamicColorsEnabled)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              localizations.dynamicColorsEnabledWarning,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? colors.onPrimary : colors.onSurface,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildGlassmorphismCard(
    BuildContext context, {
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
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
          child: child,
        ),
      ),
    );
  }
}
