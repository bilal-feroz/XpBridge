import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';

class AgeBandScreen extends StatefulWidget {
  const AgeBandScreen({super.key});

  @override
  State<AgeBandScreen> createState() => _AgeBandScreenState();
}

class _AgeBandScreenState extends State<AgeBandScreen> {
  AgeBand? _selected;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    _selected ??= appState.ageBand;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select your age',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We adapt missions and safety rules for your age band.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  children: [
                    _ageCard(
                      title: '15-17',
                      subtitle: 'Curated missions, time caps, safety checks.',
                      selected: _selected == AgeBand.teen,
                      icon: Icons.shield_moon_rounded,
                      onTap: () => setState(() => _selected = AgeBand.teen),
                    ),
                    const SizedBox(height: 16),
                    _ageCard(
                      title: '18-21',
                      subtitle: 'Full catalog access with pro expectations.',
                      selected: _selected == AgeBand.adult,
                      icon: Icons.flash_on_rounded,
                      onTap: () => setState(() => _selected = AgeBand.adult),
                    ),
                  ],
                ),
              ),
              XPButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: _selected == null
                    ? null
                    : () {
                        appState.setAgeBand(_selected!);
                        context.goNamed('studentSetup');
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ageCard({
    required String title,
    required String subtitle,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: XPCard(
        onTap: onTap,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withValues(alpha: 0.16)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: selected ? AppTheme.primary : Colors.grey.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppTheme.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
