import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/student_profile.dart';
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
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _educationController = TextEditingController();
  final _portfolioController = TextEditingController();
  final Set<String> _skills = {};
  double _hours = 10;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    const spacing = 10.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient accent
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete your profile',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Help startups get to know you',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const XPSectionTitle(title: 'Basic Info'),
                      const SizedBox(height: 10),
                      XPCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'Enter your name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.cardBackground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _educationController,
                              decoration: InputDecoration(
                                labelText: 'Education',
                                hintText: 'e.g., BSc Computer Science - MIT',
                                prefixIcon: const Icon(Icons.school_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.cardBackground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _bioController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Bio',
                                hintText: 'Tell startups about yourself...',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 48),
                                  child: Icon(Icons.edit_note),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.cardBackground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _portfolioController,
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: 'Portfolio URL (optional)',
                                hintText: 'https://yourportfolio.com',
                                prefixIcon: const Icon(Icons.link),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.cardBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const XPSectionTitle(title: 'Select your skills (2-4)'),
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
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.primary,
                                inactiveTrackColor: AppTheme.cardBackground,
                                thumbColor: AppTheme.primary,
                                overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12,
                                ),
                                trackHeight: 8,
                              ),
                              child: Slider(
                                min: 2,
                                max: 25,
                                divisions: 23,
                                value: _hours,
                                label: '${_hours.round()} hrs',
                                onChanged: (v) => setState(() => _hours = v),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.success.withValues(alpha: 0.15),
                                    AppTheme.success.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.success.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: AppTheme.successDark,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_hours.round()} hours per week',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.successDark,
                                    ),
                                  ),
                                ],
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
                          _skills.clear();
                          _hours = 10;
                        }),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primary.withValues(alpha: 0.08),
                              AppTheme.primary.withValues(alpha: 0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: XPCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primary,
                                          AppTheme.primaryDark,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _nameController.text.isNotEmpty
                                            ? _nameController.text[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _nameController.text.isNotEmpty
                                              ? _nameController.text
                                              : 'Your Name',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: AppTheme.text,
                                          ),
                                        ),
                                        if (_educationController.text.isNotEmpty)
                                          Text(
                                            _educationController.text,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.schedule,
                                          size: 14,
                                          color: AppTheme.successDark,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_hours.round()} hrs',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.successDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (_skills.isEmpty ? ['Add skills'] : _skills)
                                    .map(
                                      (skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: _skills.isNotEmpty
                                              ? LinearGradient(
                                                  colors: [
                                                    AppTheme.primary.withValues(alpha: 0.15),
                                                    AppTheme.primary.withValues(alpha: 0.08),
                                                  ],
                                                )
                                              : null,
                                          color: _skills.isEmpty ? AppTheme.cardBackground : null,
                                          borderRadius: BorderRadius.circular(12),
                                          border: _skills.isNotEmpty
                                              ? Border.all(
                                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                                )
                                              : null,
                                        ),
                                        child: Text(
                                          skill,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: _skills.isNotEmpty
                                                ? AppTheme.primary
                                                : AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              XPButton(
                label: 'Save & Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed:
                    (_nameController.text.isNotEmpty && _skills.length >= 2)
                    ? () async {
                        final prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString('user_email') ?? '';

                        final profile = StudentProfile(
                          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                          name: _nameController.text,
                          email: email,
                          bio: _bioController.text.isNotEmpty
                              ? _bioController.text
                              : null,
                          education: _educationController.text.isNotEmpty
                              ? _educationController.text
                              : null,
                          skills: _skills.toList(),
                          availabilityHours: _hours,
                          portfolioUrl: _portfolioController.text.isNotEmpty
                              ? _portfolioController.text
                              : null,
                          createdAt: DateTime.now(),
                          xpPoints: 0,
                          level: 1,
                          missionsCompletedCount: 0,
                        );

                        // Save profile data to shared_preferences
                        await prefs.setString('profile_name', _nameController.text);
                        await prefs.setString('profile_bio', _bioController.text);
                        await prefs.setString('profile_education', _educationController.text);
                        await prefs.setStringList('profile_skills', _skills.toList());
                        await prefs.setDouble('profile_hours', _hours);

                        // Mark as logged in for auto-login on next app launch
                        await prefs.setBool('is_logged_in', true);

                        if (!context.mounted) return;
                        appState.saveStudentProfile(profile);
                        context.goNamed('studentDashboard');
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
