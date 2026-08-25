import 'package:flutter/material.dart';
import 'package:my_special_app/utils/app_animations.dart';

/// Cross-fades children without the default [AnimatedSwitcher] slide, which
/// can make text feel laggy and previously ghosted labels on Safari.
class FadeSwitcher extends StatelessWidget {
  const FadeSwitcher({
    super.key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.expand = false,
  });

  final Widget child;
  final Duration duration;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimations.of(context, duration),
      switchInCurve: AppAnimations.inCurve,
      switchOutCurve: AppAnimations.outCurve,
      layoutBuilder: (current, previous) {
        return Stack(
          alignment: Alignment.center,
          fit: expand ? StackFit.expand : StackFit.loose,
          children: [
            ...previous,
            if (current != null) current,
          ],
        );
      },
      transitionBuilder: AppAnimations.fade,
      child: child,
    );
  }
}

/// Scales with a transform only — no layout animation.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.scale = 0.98,
  });

  final Widget child;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.press,
    );
    _scale = Tween<double>(begin: 1, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.inCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _forward() {
    if (AppAnimations.reduceMotion(context)) return;
    _controller.forward();
  }

  void _reverse() {
    if (AppAnimations.reduceMotion(context)) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _forward(),
      onPointerUp: (_) => _reverse(),
      onPointerCancel: (_) => _reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class AnimatedHeart extends StatelessWidget {
  const AnimatedHeart({
    super.key,
    required this.isFavorite,
    this.size = 18,
    this.color,
    this.outlineColor,
  });

  final bool isFavorite;
  final double size;
  final Color? color;
  final Color? outlineColor;

  @override
  Widget build(BuildContext context) {
    final filled = color ?? Theme.of(context).colorScheme.secondary;
    final outline = outlineColor ?? Theme.of(context).colorScheme.outline;
    return FadeSwitcher(
      duration: AppAnimations.fast,
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        key: ValueKey(isFavorite),
        size: size,
        color: isFavorite ? filled : outline,
      ),
    );
  }
}
