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
  bool _statsExpanded = false;

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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Level',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'L$level',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$xpPoints XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.text,
                                ),
                              ),
                              if (nextLevel != null)
                                Text(
                                  '${nextLevel - xpPoints} to L${level + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: AppTheme.cardBackground,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats row (collapsible)
                GestureDetector(
                  onTap: () => setState(() => _statsExpanded = !_statsExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Your Stats',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _statsExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_statsExpanded) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
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
                          height: 35,
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
                          height: 35,
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
              ],
            ),
          ),
            // Filters section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  const SizedBox(height: 10),
                  // Quick Actions (icon-only, compact)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _IconActionChip(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Skills',
                          onTap: () => context.pushNamed('studentProfile'),
                        ),
                        _IconActionChip(
                          icon: Icons.description_rounded,
                          label: 'Apps',
                          onTap: () => context.pushNamed('myApplications'),
                        ),
                        _IconActionChip(
                          icon: Icons.smart_toy_rounded,
                          label: 'AI Chat',
                          onTap: () => context.pushNamed('aiChat'),
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
            // Section divider
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Recommended for you',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_selectedIndustry != null || _selectedSkill != null)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _selectedIndustry = null;
                        _selectedSkill = null;
                      }),
                      icon: const Icon(Icons.clear, size: 14),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 11),
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: _filteredStartups.length,
                      itemBuilder: (context, index) {
                        final startup = _filteredStartups[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < _filteredStartups.length - 1 ? 20 : 0,
                          ),
                          child: _StartupCard(
                            startup: startup,
                            studentSkills: studentProfile?.skills ?? [],
                            onTap: () => context.pushNamed(
                              'startupDetail',
                              pathParameters: {'id': startup.id},
                            ),
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

class _StatItem extends StatefulWidget {
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
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem> {
  late int _targetValue;
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _targetValue = int.tryParse(widget.value) ?? 0;
    _currentValue = 0;
    _animateValue();
  }

  void _animateValue() {
    if (_targetValue == 0) return;
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      if (_currentValue < _targetValue) {
        setState(() {
          _currentValue = (_currentValue + (_targetValue / 10).ceil())
              .clamp(0, _targetValue);
        });
        _animateValue();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withValues(alpha: 0.12),
                widget.color.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          _currentValue.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.text,
          ),
        ),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Get Started'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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

class _StartupCard extends StatefulWidget {
  const _StartupCard({
    required this.startup,
    required this.studentSkills,
    required this.onTap,
  });

  final StartupProfile startup;
  final List<String> studentSkills;
  final VoidCallback onTap;

  @override
  State<_StartupCard> createState() => _StartupCardState();
}

class _StartupCardState extends State<_StartupCard> {
  bool _isPressed = false;

  int get _matchingSkills {
    return widget.startup.requiredSkills
        .where((skill) => widget.studentSkills.contains(skill))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final matchCount = _matchingSkills;
    final hasMatch = matchCount > 0;
    final primaryRole =
        widget.startup.openRoles.isNotEmpty ? widget.startup.openRoles.first : null;
    final matchPercentage = widget.startup.requiredSkills.isNotEmpty
        ? ((matchCount / widget.startup.requiredSkills.length) * 100).round()
        : 0;

    return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: XPCard(
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
                      widget.startup.companyName[0].toUpperCase(),
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
                        widget.startup.companyName,
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
                          widget.startup.industry,
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
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1.5,
                        color: AppTheme.success.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$matchPercentage% match',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.successDark,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.startup.description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.startup.openRoles.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.startup.openRoles.take(2).map((role) {
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
              children: widget.startup.requiredSkills.map((skill) {
                final isMatch = widget.studentSkills.contains(skill);
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

// Icon Action Chip Widget (compact version for quick actions)
class _IconActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
