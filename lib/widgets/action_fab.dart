import 'package:material_ui/material_ui.dart';
import 'package:tarefas/widgets/orb_glass.dart';

class FabAction {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  const FabAction({required this.icon, required this.label, this.onPressed});
}

class ActionFab extends StatefulWidget {
  final FabAction primary;
  final List<FabAction> secondary;
  final bool busy;
  const ActionFab({
    super.key,
    required this.primary,
    required this.secondary,
    this.busy = false,
  });

  @override
  State<ActionFab> createState() => _ActionFabState();
}

class _ActionFabState extends State<ActionFab> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomRight,
          child: _open
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final a in widget.secondary)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassFab(
                          onPressed: () {
                            setState(() => _open = false);
                            a.onPressed?.call();
                          },
                          icon: Icon(a.icon),
                          label: a.label,
                        ),
                      ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
        GlassFab(
          onPressed: _toggle,
          icon: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: Icon(_open ? Icons.add : Icons.more_horiz),
          ),
        ),
        const SizedBox(height: 12),
        GlassFab(
          onPressed: widget.busy ? null : widget.primary.onPressed,
          icon: widget.busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                )
              : Icon(widget.primary.icon),
          label: widget.primary.label,
        ),
      ],
    );
  }
}

class InsetFabLocation extends FloatingActionButtonLocation {
  final double bottomInset;
  final double endMargin;
  const InsetFabLocation({required this.bottomInset, this.endMargin = 16});

  static InsetFabLocation aboveSystemBar(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return InsetFabLocation(bottomInset: bottom + 16);
  }

  static InsetFabLocation aboveNavBar(BuildContext context) {
    final navHeight = MediaQuery.paddingOf(context).bottom;
    return InsetFabLocation(bottomInset: navHeight + 16, endMargin: 20);
  }

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final x = geometry.scaffoldSize.width -
        geometry.floatingActionButtonSize.width -
        endMargin;
    final y = geometry.contentBottom -
        geometry.floatingActionButtonSize.height -
        bottomInset;
    return Offset(x, y);
  }
}
