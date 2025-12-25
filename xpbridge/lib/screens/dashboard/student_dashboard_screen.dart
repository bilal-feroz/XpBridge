import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/startup_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_app_bar.dart';
import '../../widgets/xp_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String? _selectedIndustry;
  String? _selectedSkill;

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

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final studentProfile = appState.studentProfile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            XPAppBar(
              title: 'Discover Startups',
              subtitle: 'Find micro-projects that match your skills',
              showBack: false,
              trailing: IconButton(
                onPressed: () => context.pushNamed('studentProfile'),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    studentProfile?.name.isNotEmpty == true
                        ? studentProfile!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
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
                        ),
                        if (studentProfile != null)
                          ...studentProfile.skills.map(
                            (skill) => _FilterChip(
                              label: skill,
                              isSelected: _selectedSkill == skill,
                              onTap: () =>
                                  setState(() => _selectedSkill = skill),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredStartups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No startups found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedIndustry = null;
                              _selectedSkill = null;
                            }),
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ),
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
            context.pushNamed('myApplications');
          } else if (index == 2) {
            context.pushNamed('studentProfile');
          }
        },
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: XPCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      startup.companyName[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        fontSize: 20,
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
                        startup.companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          startup.industry,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$matchCount match${matchCount > 1 ? 'es' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              startup.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (startup.openRoles.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: startup.openRoles.take(2).map((role) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
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
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
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
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: isMatch
                        ? Border.all(color: Colors.green.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMatch ? Colors.green.shade700 : Colors.black87,
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: 'Applications',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppTheme.primary : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppTheme.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
