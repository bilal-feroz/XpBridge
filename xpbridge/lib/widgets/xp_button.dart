import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class XPButton extends StatefulWidget {
  const XPButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tonal = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool tonal;
  final bool expand;

  @override
  State<XPButton> createState() => _XPButtonState();
}

class _XPButtonState extends State<XPButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon: widget.icon != null
          ? Icon(widget.icon, size: 20)
          : const SizedBox.shrink(),
      label: Text(
        widget.label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.tonal
            ? AppTheme.primary.withValues(alpha: 0.12)
            : AppTheme.primary,
        foregroundColor: widget.tonal ? AppTheme.primary : Colors.white,
        minimumSize: const Size.fromHeight(52),
        shadowColor: Colors.black.withValues(alpha: widget.tonal ? 0 : 0.18),
      ),
    );

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: widget.expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}
