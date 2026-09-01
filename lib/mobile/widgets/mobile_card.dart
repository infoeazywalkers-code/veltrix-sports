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
      child: onTap != null
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
                Text(title, style: M.cardTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: M.cardBody),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null) ...[
            const SizedBox(width: M.sm),
            const Icon(Icons.chevron_right, color: M.muted, size: 20),
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

  const MBanner({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(M.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(M.rXl),
      ),
      child: child,
    );
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
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: M.lg,
        vertical: M.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(M.rXl),
      ),
      child: child,
    );
  }
}

void main() => runApp(MaterialApp(
  theme: M.theme,
  home: Scaffold(
    backgroundColor: M.bg,
    body: ListView(
      padding: const EdgeInsets.all(M.base),
      children: const [
        MCard(child: Text('Hello from MCard')),
        SizedBox(height: M.md),
        MBanner(
          backgroundColor: M.navy,
          child: Text('Banner', style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: M.md),
        MInfoCard(
          icon: Icons.star,
          iconColor: M.blue,
          title: 'Info Card',
          subtitle: 'Subtitle text here',
        ),
      ],
    ),
  ),
));
