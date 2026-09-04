import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/brand.dart';
import '../widgets/footer_group.dart';
import '../widgets/footer_social.dart';

class VeltrixFooter extends StatelessWidget {
  final VoidCallback? onNavigate;
  const VeltrixFooter({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 800;
    const groups = [
      ('ATHLETES', ['Features', 'Training plans', 'Find a coach', 'Premium', 'Mobile app']),
      ('COACHES', ['Coach platform', 'Coach pricing', 'Coach directory', 'Education', 'Resources']),
      ('TRAIN', ['Calendar', 'Performance', 'Strength', 'Events', 'Device sync']),
      ('COMPANY', ['About Veltrix', 'Careers', 'Partners', 'Contact', 'Support']),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(desktop ? 40 : 22, 42, desktop ? 40 : 22, 24),
      decoration: BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: desktop ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: desktop ? 240 : double.infinity,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Brand(),
                        SizedBox(width: 10),
                        Text(
                          'VELTRIX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Plan with confidence. Train with purpose. Perform when it matters.',
                      style: TextStyle(color: Colors.white60, height: 1.5, fontSize: 13),
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        FooterSocial(Icons.camera_alt_outlined),
                        SizedBox(width: 8),
                        FooterSocial(Icons.play_arrow_rounded),
                        SizedBox(width: 8),
                        FooterSocial(Icons.facebook_rounded),
                        SizedBox(width: 8),
                        FooterSocial(Icons.alternate_email_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: desktop ? 46 : 0, height: desktop ? 0 : 32),
              if (desktop)
                Expanded(
                  child: Wrap(
                    spacing: 46,
                    runSpacing: 28,
                    children: groups
                        .map((g) => SizedBox(width: 130, child: FooterGroup(title: g.$1, links: g.$2)))
                        .toList(),
                  ),
                )
              else
                Wrap(
                  spacing: 24,
                  runSpacing: 28,
                  children: groups
                      .map((g) => SizedBox(width: 140, child: FooterGroup(title: g.$1, links: g.$2)))
                      .toList(),
                ),
            ],
          ),
          const SizedBox(height: 36),
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const Text(
                '\u00a9 2026 Veltrix Sports. All rights reserved.',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              Wrap(
                spacing: 16,
                children: const [
                  Text('Privacy', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('Terms', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('Cookies', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('English \u00b7 India', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

