// ignore_for_file: deprecated_member_use
import 'dart:ui';

import 'package:material_ui/material_ui.dart';

class OrbGlass extends StatelessWidget {
  final ImageFilter filter;
  final Widget? child;
  final BorderRadius borderRadius;

  static ImageFilter lowBlur = ImageFilter.blur(
    sigmaX: 3,
    sigmaY: 3,
    tileMode: TileMode.clamp,
  );
  static ImageFilter medBlur = ImageFilter.blur(
    sigmaX: 8,
    sigmaY: 8,
    tileMode: TileMode.clamp,
  );

  static ImageFilter navBlur = ImageFilter.blur(
    sigmaX: 6,
    sigmaY: 6,
    tileMode: TileMode.clamp,
  );

  static ImageFilter highBlur = ImageFilter.blur(
    sigmaX: 20,
    sigmaY: 20,
    tileMode: TileMode.clamp,
  );
  static ImageFilter heroBlur = ImageFilter.blur(
    sigmaX: 28,
    sigmaY: 28,
    tileMode: TileMode.clamp,
  );

  const OrbGlass({
    super.key,
    required this.filter,
    this.child,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: filter,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  static Widget autoReduce({
    Key? key,
    required bool reduce,
    required ImageFilter filter,
    required BorderRadius borderRadius,
    required Color fallbackColor,
    Widget? child,
  }) {
    if (reduce) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: ColoredBox(
          color: fallbackColor,
          child: child ?? const SizedBox.shrink(),
        ),
      );
    }
    return OrbGlass(
      key: key,
      filter: filter,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

BoxDecoration liquidGlassDecoration(
  ThemeData theme, {
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(24)),
  bool hero = false,
  Color? tint,
  double opacityMultiplier = 1.0,
}) {
  final isLight = theme.brightness == Brightness.light;
  final surface = tint ?? (isLight ? Colors.white : theme.colorScheme.surface);
  final baseAlpha = hero ? (isLight ? 0.65 : 0.40) : (isLight ? 0.50 : 0.28);

  return BoxDecoration(
    borderRadius: borderRadius,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        surface.withOpacity(
          (baseAlpha * 1.15 * opacityMultiplier).clamp(0.0, 0.95),
        ),
        surface.withOpacity(
          (baseAlpha * 0.70 * opacityMultiplier).clamp(0.0, 0.95),
        ),
      ],
      stops: const [0.0, 1.0],
    ),
    border: Border.all(
      color: isLight
          ? Colors.white.withOpacity(0.65)
          : Colors.white.withOpacity(0.18),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: isLight
            ? Colors.black.withOpacity(0.06)
            : Colors.black.withOpacity(0.25),
        blurRadius: hero ? 28 : 20,
        offset: const Offset(0, 8),
      ),
      if (isLight)
        BoxShadow(
          color: Colors.white.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
    ],
  );
}

BoxDecoration orbGlassDecoration(
  ThemeData theme, {
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(40)),
  bool hero = false,
}) {
  return liquidGlassDecoration(theme, borderRadius: borderRadius, hero: hero);
}

class LiquidBackdrop extends StatelessWidget {
  final Widget child;
  final List<Color>? orbColors;
  const LiquidBackdrop({super.key, required this.child, this.orbColors});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final tertiary = Theme.of(context).colorScheme.tertiary;

    final c1 = orbColors != null && orbColors!.isNotEmpty
        ? orbColors![0]
        : (isDark
              ? primary.withOpacity(0.28)
              : const Color(0xFF6C9EFF).withOpacity(0.24));
    final c2 = orbColors != null && orbColors!.length > 1
        ? orbColors![1]
        : (isDark
              ? tertiary.withOpacity(0.25)
              : const Color(0xFFFFB2A6).withOpacity(0.25));
    final c3 = isDark
        ? const Color(0xFF2E7D32).withOpacity(0.18)
        : const Color(0xFFC7F9CC).withOpacity(0.35);

    return Stack(
      children: [

        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF0F141C) : const Color(0xFFF6F8FC),
          ),
        ),

        Positioned(
          top: -60,
          left: -40,
          child: _LiquidOrb(size: 260, color: c1),
        ),
        Positioned(
          top: 140,
          right: -50,
          child: _LiquidOrb(size: 240, color: c2),
        ),
        Positioned(
          bottom: 40,
          left: -30,
          child: _LiquidOrb(size: 220, color: c3),
        ),

        Positioned.fill(child: child),
      ],
    );
  }
}

class _LiquidOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _LiquidOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0.0)],
            stops: const [0.2, 1.0],
          ),
        ),
      ),
    );
  }
}

class GlassPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final ImageFilter? filter;
  final bool hero;

  const GlassPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.hero = false,
    this.filter,
  });

  @override
  State<GlassPressable> createState() => _GlassPressableState();
}

class _GlassPressableState extends State<GlassPressable> {
  bool _pressed = false;

  ImageFilter get _filter => widget.filter ?? OrbGlass.medBlur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: OrbGlass(
            filter: _filter,
            borderRadius: widget.borderRadius,
            child: Container(
              decoration:
                  orbGlassDecoration(
                    theme,
                    borderRadius: widget.borderRadius,
                    hero: widget.hero,
                  ).copyWith(

                    color: _pressed
                        ? theme.colorScheme.surface.withOpacity(0.75)
                        : null,
                  ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingGlassBar extends StatelessWidget {
  final double height;
  final Widget child;
  final BorderRadius borderRadius;

  const FloatingGlassBar({
    super.key,
    this.height = 72,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(40)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: bottomPadding > 0 ? bottomPadding + 8 : 24,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: OrbGlass(
            filter: OrbGlass.navBlur,
            borderRadius: borderRadius,
            child: Container(
              height: height,
              decoration: orbGlassDecoration(theme, borderRadius: borderRadius),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final bool showBottomBorder;

  const GlassAppBar({
    super.key,
    this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.height = kToolbarHeight,
    this.showBottomBorder = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ClipRect(
      child: OrbGlass(
        filter: OrbGlass.navBlur,
        child: Container(
          decoration: BoxDecoration(
            color: (isLight ? Colors.white : theme.colorScheme.surface).withOpacity(isLight ? 0.65 : 0.40),
            border: showBottomBorder
                ? Border(
                    bottom: BorderSide(
                      color: isLight ? Colors.white.withOpacity(0.65) : Colors.white.withOpacity(0.12),
                      width: 1.1,
                    ),
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.03 : 0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: AppBar(
              title: title,
              centerTitle: centerTitle,
              actions: actions,
              leading: leading,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassFab extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? label;
  final Color? accentColor;

  const GlassFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.accentColor,
  });

  @override
  State<GlassFab> createState() => _GlassFabState();
}

class _GlassFabState extends State<GlassFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final primary = widget.accentColor ?? scheme.primary;

    final isIconOnly = widget.label == null;
    final borderRadius = BorderRadius.circular(isIconOnly ? 28 : 22);

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: OrbGlass(
            filter: OrbGlass.heroBlur,
            borderRadius: borderRadius,
            child: Container(
              width: isIconOnly ? 54 : null,
              height: isIconOnly ? 54 : null,
              padding: isIconOnly
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              alignment: isIconOnly ? Alignment.center : null,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withOpacity(isLight ? 0.90 : 0.82),
                    primary.withOpacity(isLight ? 0.74 : 0.66),
                  ],
                ),
                border: Border.all(
                  color: isLight
                      ? Colors.white.withOpacity(0.70)
                      : Colors.white.withOpacity(0.28),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: isIconOnly
                  ? IconTheme(
                      data: const IconThemeData(color: Colors.white, size: 26),
                      child: widget.icon,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconTheme(
                          data: const IconThemeData(color: Colors.white, size: 19),
                          child: widget.icon,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.label!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
