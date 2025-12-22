import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';
import '../../widgets/xp_chip.dart';
import '../../widgets/xp_section_title.dart';

class StudentSetupScreen extends StatefulWidget {
  const StudentSetupScreen({super.key});

  @override
  State<StudentSetupScreen> createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  String? _track;
  final Set<String> _skills = {};
  double _hours = 10;

  @override
  void initState() {
    super.initState();
    _track = DummyData.tracks.first;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final spacing = 10.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set up your lane',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We use this to recommend the best missions.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const XPSectionTitle(title: 'Pick a track'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: DummyData.tracks
                            .map(
                              (track) => XPChoiceChip(
                                label: track,
                                selected: _track == track,
                                onSelected: (_) =>
                                    setState(() => _track = track),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      const XPSectionTitle(title: 'Add 2-4 skills'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: DummyData.skillPool
                            .map(
                              (skill) => XPChoiceChip(
                                label: skill,
                                selected: _skills.contains(skill),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (_skills.length < 4) {
                                        _skills.add(skill);
                                      }
                                    } else {
                                      _skills.remove(skill);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      const XPSectionTitle(title: 'Availability (hrs / week)'),
                      const SizedBox(height: 8),
                      XPCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              min: 2,
                              max: 25,
                              divisions: 23,
                              value: _hours,
                              label: '${_hours.round()} hrs',
                              onChanged: (v) => setState(() => _hours = v),
                            ),
                            Text(
                              '${_hours.round()} hours per week',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'We keep minors below 15 hrs/week with breaks.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      XPSectionTitle(
                        title: 'Preview',
                        actionLabel: 'Reset',
                        onActionTap: () => setState(() {
                          _track = DummyData.tracks.first;
                          _skills.clear();
                          _hours = 10;
                        }),
                      ),
                      const SizedBox(height: 8),
                      XPCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _track ?? 'Track',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 18),
                                    const SizedBox(width: 6),
                                    Text('${_hours.round()} hrs'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  (_skills.isEmpty ? ['Add skills'] : _skills)
                                      .map(
                                        (skill) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            skill,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              XPButton(
                label: 'Save & see missions',
                icon: Icons.arrow_forward_rounded,
                onPressed: (_track != null && _skills.length >= 2)
                    ? () {
                        final profile = UserProfile(
                          track: _track!,
                          skills: _skills.toList(),
                          availabilityHours: _hours,
                        );
                        appState.saveProfile(profile);
                        context.goNamed('missionFeed');
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
