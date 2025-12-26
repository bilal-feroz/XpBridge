import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/application.dart';
import '../../models/student_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_card.dart';

class StartupDashboardScreen extends StatefulWidget {
  const StartupDashboardScreen({super.key});

  @override
  State<StartupDashboardScreen> createState() => _StartupDashboardScreenState();
}

class _StartupDashboardScreenState extends State<StartupDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSkill;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markApplicationCompleted(Application application) async {
    final appState = AppStateScope.of(context);
    await appState.updateApplicationStatus(
      application.id,
      ApplicationStatus.completed,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked as completed'),
        backgroundColor: AppTheme.successDark,
      ),
    );
  }

  void _showFeedbackSheet(Application application) {
    final appState = AppStateScope.of(context);
    StudentProfile? student;
    try {
      student = DummyData.students
          .firstWhere((s) => s.id == application.studentId);
    } catch (_) {
      student = null;
    }
    final skills = student?.skills ?? [];
    final strengthsOptions = [
      'Ownership',
      'Communication',
      'Craft',
      'Collaboration',
      'Speed',
    ];
    final growthOptions = [
      'Planning',
      'Documentation',
      'Testing',
      'Autonomy',
      'Focus',
    ];

    int rating = application.mentorRating ?? 0;
    final feedbackController = TextEditingController(
      text: application.mentorFeedbackText ?? '',
    );
    final selectedStrengths = <String>{...application.strengths};
    final selectedGrowth = <String>{...application.growthAreas};
    final endorsedSkills = <String>{...application.endorsedSkills};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.star_rate_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Leave mentor feedback',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppTheme.text,
                                ),
                              ),
                              Text(
                                application.studentName,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return IconButton(
                            onPressed: () => setState(() => rating = starIndex),
                            icon: Icon(
                              starIndex <= rating
                                  ? Icons.star
                                  : Icons.star_border_rounded,
                              color: AppTheme.primary,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Strengths',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: strengthsOptions.map((item) {
                          final selected = selectedStrengths.contains(item);
                          return ChoiceChip(
                            label: Text(item),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                value
                                    ? selectedStrengths.add(item)
                                    : selectedStrengths.remove(item);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Growth areas',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: growthOptions.map((item) {
                          final selected = selectedGrowth.contains(item);
                          return ChoiceChip(
                            label: Text(item),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                value
                                    ? selectedGrowth.add(item)
                                    : selectedGrowth.remove(item);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Endorse up to 2 skills',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills.map((skill) {
                          final selected = endorsedSkills.contains(skill);
                          final canSelect = selected || endorsedSkills.length < 2;
                          return FilterChip(
                            label: Text(skill),
                            selected: selected,
                            onSelected: canSelect
                                ? (value) {
                                    setState(() {
                                      if (value) {
                                        endorsedSkills.add(skill);
                                      } else {
                                        endorsedSkills.remove(skill);
                                      }
                                    });
                                  }
                                : null,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: feedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Feedback (optional)',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(Icons.feedback_outlined),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.cardBackground,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (rating == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please add a rating before submitting.'),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                              return;
                            }
                            await appState.saveMentorFeedback(
                              application.id,
                              rating: rating,
                              feedback: feedbackController.text.trim(),
                              strengths: selectedStrengths.toList(),
                              growthAreas: selectedGrowth.toList(),
                              endorsedSkills: endorsedSkills.toList(),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Feedback saved'),
                                backgroundColor: AppTheme.successDark,
                              ),
                            );
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const Text(
                            'Save feedback',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<StudentProfile> get _filteredStudents {
    var students = DummyData.students;

    if (_selectedSkill != null) {
      students = students
          .where((s) => s.skills.contains(_selectedSkill))
          .toList();
    }

    return students;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final startupProfile = appState.startupProfile;
    final startupApplications = startupProfile != null
        ? appState.getApplicationsForStartup(startupProfile.id)
        : <Application>[];
    final applications =
        startupApplications.isNotEmpty ? startupApplications : appState.applications;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  bottom: BorderSide(color: AppTheme.cardBackground),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              startupProfile?.companyName ?? 'Your Company',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Find Talent',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pushNamed('startupProfile'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              startupProfile?.companyName.isNotEmpty == true
                                  ? startupProfile!.companyName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.people_rounded,
                            label: 'Students',
                            value: '${_filteredStudents.length}',
                            color: AppTheme.primary,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.surface,
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.inbox_rounded,
                            label: 'Learners',
                            value: '${applications.length}',
                            color: AppTheme.success,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.surface,
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.work_rounded,
                            label: 'Roles',
                            value: '${startupProfile?.openRoles.length ?? 0}',
                            color: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(text: 'Students (${_filteredStudents.length})'),
                  Tab(text: 'Learners (${applications.length})'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BrowseStudentsTab(
                    students: _filteredStudents,
                    startupSkills: startupProfile?.requiredSkills ?? [],
                    selectedSkill: _selectedSkill,
                    onSkillSelected: (skill) =>
                        setState(() => _selectedSkill = skill),
                  ),
                  _ApplicationsTab(
                    applications: applications,
                    onMarkCompleted: _markApplicationCompleted,
                    onLeaveFeedback: _showFeedbackSheet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            _tabController.animateTo(1);
          } else if (index == 2) {
            context.pushNamed('startupProfile');
          }
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.text,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BrowseStudentsTab extends StatelessWidget {
  const _BrowseStudentsTab({
    required this.students,
    required this.startupSkills,
    required this.selectedSkill,
    required this.onSkillSelected,
  });

  final List<StudentProfile> students;
  final List<String> startupSkills;
  final String? selectedSkill;
  final ValueChanged<String?> onSkillSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Skills',
                  isSelected: selectedSkill == null,
                  onTap: () => onSkillSelected(null),
                ),
                ...startupSkills.map(
                  (skill) => _FilterChip(
                    label: skill,
                    isSelected: selectedSkill == skill,
                    onTap: () => onSkillSelected(skill),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: students.isEmpty
              ? _EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No students found',
                  subtitle: 'Try adjusting your filters',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _StudentCard(
                      student: student,
                      startupSkills: startupSkills,
                      onTap: () => context.pushNamed(
                        'studentDetail',
                        pathParameters: {'id': student.id},
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ApplicationsTab extends StatelessWidget {
  const _ApplicationsTab({
    required this.applications,
    required this.onMarkCompleted,
    required this.onLeaveFeedback,
  });

  final List<Application> applications;
  final ValueChanged<Application> onMarkCompleted;
  final ValueChanged<Application> onLeaveFeedback;

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return _EmptyState(
        icon: Icons.inbox_rounded,
        title: 'No applications yet',
        subtitle: 'Students will appear here when they apply',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return _ApplicationCard(
          application: application,
          onMarkCompleted: () => onMarkCompleted(application),
          onLeaveFeedback: () => onLeaveFeedback(application),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  )
                : null,
            color: isSelected ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: AppTheme.cardBackground, width: 1.5),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.startupSkills,
    required this.onTap,
  });

  final StudentProfile student;
  final List<String> startupSkills;
  final VoidCallback onTap;

  int get _matchingSkills {
    return student.skills
        .where((skill) => startupSkills.contains(skill))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final matchCount = _matchingSkills;
    final hasMatch = matchCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: XPCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.15),
                        AppTheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      student.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppTheme.text,
                        ),
                      ),
                      if (student.education != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          student.education!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasMatch)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.success, AppTheme.successDark],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$matchCount match',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${student.availabilityHours.round()} hrs/wk',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (student.bio != null) ...[
              const SizedBox(height: 14),
              Text(
                student.bio!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: student.skills.map((skill) {
                final isMatch = startupSkills.contains(skill);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isMatch
                        ? AppTheme.success.withValues(alpha: 0.12)
                        : AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: isMatch
                        ? Border.all(
                            color: AppTheme.success.withValues(alpha: 0.3),
                          )
                        : null,
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMatch ? AppTheme.successDark : AppTheme.text,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.onMarkCompleted,
    required this.onLeaveFeedback,
  });

  final Application application;
  final VoidCallback onMarkCompleted;
  final VoidCallback onLeaveFeedback;

  Color get _statusColor {
    switch (application.status) {
      case ApplicationStatus.pending:
        return AppTheme.warning;
      case ApplicationStatus.accepted:
        return AppTheme.success;
      case ApplicationStatus.rejected:
        return AppTheme.error;
      case ApplicationStatus.interviewing:
        return AppTheme.primary;
      case ApplicationStatus.hired:
        return const Color(0xFF8B5CF6);
      case ApplicationStatus.completed:
        return AppTheme.successDark;
    }
  }

  String get _statusText {
    switch (application.status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.interviewing:
        return 'Interviewing';
      case ApplicationStatus.hired:
        return 'In Progress';
      case ApplicationStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = application.status == ApplicationStatus.completed;
    final hasFeedback = application.mentorRating != null ||
        application.mentorFeedbackText?.isNotEmpty == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: XPCard(
        padding: const EdgeInsets.all(20),
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.15),
                        AppTheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      application.studentName[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.text,
                        ),
                      ),
                      if (application.roleTitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          application.roleTitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (application.message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '"${application.message}"',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isCompleted)
                  TextButton.icon(
                    onPressed: onMarkCompleted,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Completed'),
                  )
                else
                  TextButton.icon(
                    onPressed: onLeaveFeedback,
                    icon: Icon(
                      hasFeedback ? Icons.edit : Icons.star_rate_rounded,
                      color: AppTheme.primary,
                    ),
                    label: Text(
                      hasFeedback ? 'Update Feedback' : 'Leave Feedback',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                if (application.mentorRating != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${application.mentorRating}/5',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.text.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Students',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.inbox_outlined,
                activeIcon: Icons.inbox,
                label: 'Learners',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.business_outlined,
                activeIcon: Icons.business,
                label: 'Company',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primary : AppTheme.textMuted,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
