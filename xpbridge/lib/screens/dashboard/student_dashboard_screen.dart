import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/startup_profile.dart';
import '../../models/event_log_entry.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String? _selectedIndustry;
  String? _selectedSkill;
  bool _feedExpanded = true;

  List<StartupProfile> get _filteredStartups {
    var startups = DummyData.startups;

    if (_selectedIndustry != null) {
      startups = startups
          .where((s) => s.industry == _selectedIndustry)
          .toList();
    }

    if (_selectedSkill != null) {
      startups = startups
          .where((s) => s.requiredSkills.contains(_selectedSkill))
          .toList();
    }

    return startups;
  }

  int _levelBase(int level) {
    switch (level) {
      case 4:
        return 900;
      case 3:
        return 500;
      case 2:
        return 200;
      default:
        return 0;
    }
  }

  int? _nextLevelTarget(int level) {
    switch (level) {
      case 1:
        return 200;
      case 2:
        return 500;
      case 3:
        return 900;
      default:
        return null;
    }
  }

  double _levelProgress(int xp, int level) {
    final next = _nextLevelTarget(level);
    if (next == null) return 1;
    final base = _levelBase(level);
    final span = (next - base).toDouble();
    if (span <= 0) return 1;
    return ((xp - base) / span).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final studentProfile = appState.studentProfile;
    final xpPoints = studentProfile?.xpPoints ?? 0;
    final level = studentProfile?.level ?? 1;
    final progress = _levelProgress(xpPoints, level);
    final nextLevel = _nextLevelTarget(level);
    final List<EventLogEntry> feedEvents = appState.eventLog;
    final feedOptOut = appState.xpFeedOptOut;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header section
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
                              'Hello, ${studentProfile?.name.split(' ').first ?? 'there'}',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Discover Missions',
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
                        onTap: () => context.pushNamed('studentProfile'),
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
                              studentProfile?.name.isNotEmpty == true
                                  ? studentProfile!.name[0].toUpperCase()
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Level',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'L$level',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$xpPoints XP',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.text,
                                ),
                              ),
                              if (nextLevel != null)
                                Text(
                                  '${nextLevel - xpPoints} to L${level + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: AppTheme.cardBackground,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                            icon: Icons.rocket_launch_rounded,
                            label: 'Available',
                            value: '${_filteredStartups.length}',
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
                            icon: Icons.psychology_rounded,
                            label: 'Skills',
                            value: '${studentProfile?.skills.length ?? 0}',
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
                            icon: Icons.timer_rounded,
                            label: 'Hours/wk',
                            value: '${studentProfile?.availabilityHours.round() ?? 0}',
                            color: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Filters section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Industries',
                          isSelected: _selectedIndustry == null,
                          onTap: () => setState(() => _selectedIndustry = null),
                        ),
                        ...DummyData.industries
                            .take(4)
                            .map(
                              (industry) => _FilterChip(
                                label: industry,
                                isSelected: _selectedIndustry == industry,
                                onTap: () => setState(
                                  () => _selectedIndustry = industry,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Skills',
                          isSelected: _selectedSkill == null,
                          onTap: () => setState(() => _selectedSkill = null),
                          secondary: true,
                        ),
                        if (studentProfile != null)
                          ...studentProfile.skills.map(
                            (skill) => _FilterChip(
                              label: skill,
                              isSelected: _selectedSkill == skill,
                              onTap: () =>
                                  setState(() => _selectedSkill = skill),
                              secondary: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!feedOptOut && feedEvents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: XPCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'XP Happening Now',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.text,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              _feedExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onPressed: () =>
                                setState(() => _feedExpanded = !_feedExpanded),
                          ),
                        ],
                      ),
                      if (_feedExpanded)
                        ...feedEvents.take(4).map((event) {
                          final time =
                              '${event.timestamp.month}/${event.timestamp.day}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      event.firstName.isNotEmpty
                                          ? event.firstName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.displayText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.text,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$time • ${event.firstName}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredStartups.length} missions available',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedIndustry != null || _selectedSkill != null)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _selectedIndustry = null;
                        _selectedSkill = null;
                      }),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
            // List
            Expanded(
              child: _filteredStartups.isEmpty
                  ? _EmptyState(
                      onClear: () => setState(() {
                        _selectedIndustry = null;
                        _selectedSkill = null;
                      }),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredStartups.length,
                      itemBuilder: (context, index) {
                        final startup = _filteredStartups[index];
                        return _StartupCard(
                          startup: startup,
                          studentSkills: studentProfile?.skills ?? [],
                          onTap: () => context.pushNamed(
                            'startupDetail',
                            pathParameters: {'id': startup.id},
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.pushNamed('aiChat');
          } else if (index == 2) {
            context.pushNamed('myApplications');
          } else if (index == 3) {
            context.pushNamed('studentProfile');
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 32,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No missions found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your filters to find more opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Clear filters'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
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
    this.secondary = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool secondary;

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
                    colors: secondary
                        ? [AppTheme.success, AppTheme.successDark]
                        : [AppTheme.primary, AppTheme.primaryDark],
                  )
                : null,
            color: isSelected ? null : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (secondary ? AppTheme.success : AppTheme.primary)
                          .withValues(alpha: 0.3),
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

class _StartupCard extends StatelessWidget {
  const _StartupCard({
    required this.startup,
    required this.studentSkills,
    required this.onTap,
  });

  final StartupProfile startup;
  final List<String> studentSkills;
  final VoidCallback onTap;

  int get _matchingSkills {
    return startup.requiredSkills
        .where((skill) => studentSkills.contains(skill))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final matchCount = _matchingSkills;
    final hasMatch = matchCount > 0;
    final primaryRole =
        startup.openRoles.isNotEmpty ? startup.openRoles.first : null;

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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      startup.companyName[0].toUpperCase(),
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
                        startup.companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          startup.industry,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.success, AppTheme.successDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$matchCount match${matchCount > 1 ? 'es' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              startup.description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (startup.openRoles.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: startup.openRoles.take(2).map((role) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          role.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (primaryRole != null &&
                (primaryRole.learningOutcome.isNotEmpty ||
                    primaryRole.estimatedHours != null ||
                    primaryRole.durationWeeks != null)) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (primaryRole.learningOutcome.isNotEmpty)
                    Chip(
                      label: Text(primaryRole.learningOutcome),
                      backgroundColor: AppTheme.cardBackground,
                      labelStyle: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  if (primaryRole.estimatedHours != null)
                    Chip(
                      avatar: const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text('${primaryRole.estimatedHours} hrs'),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      backgroundColor: AppTheme.cardBackground,
                    ),
                  if (primaryRole.durationWeeks != null)
                    Chip(
                      avatar: const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text('${primaryRole.durationWeeks} wks'),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      backgroundColor: AppTheme.cardBackground,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: startup.requiredSkills.map((skill) {
                final isMatch = studentSkills.contains(skill);
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
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Discover',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: 'AI Advisor',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: 'Applications',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
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
