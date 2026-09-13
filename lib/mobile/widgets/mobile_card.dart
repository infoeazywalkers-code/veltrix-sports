import 'package:flutter/material.dart';
import '../theme.dart';

class MCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;

  const MCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(M.base),
      child: child,
    );

    return Card(
      color: color,
      child:
          onTap != null
              ? InkWell(
                borderRadius: BorderRadius.circular(M.rLg),
                onTap: onTap,
                child: content,
              )
              : content,
    );
  }
}

class MInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MInfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(M.rMd),
            ),
            child: Icon(icon, color: iconColor, size: M.iconMd),
          ),
          const SizedBox(width: M.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: M.adaptiveTitle(context)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: M.adaptiveCardBody(context)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null) ...[
            const SizedBox(width: M.sm),
            Icon(
              Icons.chevron_right,
              color:
                  (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF78909C)
                      : M.muted),
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}

class MBanner extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const MBanner({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(M.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(M.rXl),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(M.rXl),
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class MGradientBanner extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final EdgeInsets? padding;

  const MGradientBanner({
    super.key,
    required this.colors,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: M.lg, vertical: M.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(M.rXl),
      ),
      child: child,
    );
  }
}
