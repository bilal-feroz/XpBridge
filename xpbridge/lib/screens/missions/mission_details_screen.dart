import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../models/mission.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_app_bar.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';
import '../../widgets/xp_section_title.dart';

class MissionDetailsScreen extends StatelessWidget {
  const MissionDetailsScreen({super.key, required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isTeen = appState.isTeen;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: XPAppBar(title: mission.title, subtitle: mission.startupName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XPCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                mission.timeEstimate,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+${mission.xp} XP',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                mission.safeForTeens
                                    ? Icons.verified_rounded
                                    : Icons.warning_amber,
                                color: mission.safeForTeens
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                mission.safeForTeens ? 'Safe' : 'Advanced',
                                style: TextStyle(
                                  color: mission.safeForTeens
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      mission.summary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const XPSectionTitle(title: 'Deliverables'),
              const SizedBox(height: 10),
              XPCard(
                child: Column(
                  children: mission.deliverables
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppTheme.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
              XPSectionTitle(
                title: 'Safety rules',
                actionLabel: isTeen ? '15-17 mode' : null,
              ),
              const SizedBox(height: 10),
              XPCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTeen)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'We limit hours, keep communications in-app, and avoid sensitive data.',
                                style: TextStyle(color: Colors.orange.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isTeen) const SizedBox(height: 10),
                    ...mission.safetyNotes.map(
                      (note) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_clock_rounded,
                              color: Colors.black54,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              XPButton(
                label: 'Accept mission',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  appState.setActiveMission(mission);
                  context.pushNamed(
                    'missionWorkspace',
                    pathParameters: {'id': mission.id},
                    extra: mission,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
