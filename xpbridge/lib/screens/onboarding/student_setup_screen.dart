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
              Text(
                'Complete your profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Help startups get to know you. Missions are short, safe, and learning-first.',
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
                                fillColor: AppTheme.background,
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
                                fillColor: AppTheme.background,
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
                                fillColor: AppTheme.background,
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
                                fillColor: AppTheme.background,
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
                              'Let startups know your availability.',
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
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nameController.text.isNotEmpty
                                            ? _nameController.text
                                            : 'Your Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (_educationController.text.isNotEmpty)
                                        Text(
                                          _educationController.text,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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
                        );

                        // Save profile data to shared_preferences
                        await prefs.setString('profile_name', _nameController.text);
                        await prefs.setString('profile_bio', _bioController.text);
                        await prefs.setString('profile_education', _educationController.text);
                        await prefs.setStringList('profile_skills', _skills.toList());
                        await prefs.setDouble('profile_hours', _hours);

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
