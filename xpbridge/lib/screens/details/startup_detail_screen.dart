import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/application.dart';
import '../../models/startup_profile.dart';
import '../../models/startup_role.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';
import '../../widgets/xp_section_title.dart';

class StartupDetailScreen extends StatefulWidget {
  const StartupDetailScreen({super.key, required this.startupId});

  final String startupId;

  @override
  State<StartupDetailScreen> createState() => _StartupDetailScreenState();
}

class _StartupDetailScreenState extends State<StartupDetailScreen> {
  final _messageController = TextEditingController();
  bool _hasApplied = false;
  final Set<String> _appliedRoleTitles = {};

  StartupProfile? get _startup {
    try {
      return DummyData.startups.firstWhere((s) => s.id == widget.startupId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showApplyDialog(BuildContext context, {StartupRole? role}) {
    final roleTitle = role?.title;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roleTitle != null
                              ? 'Apply for $roleTitle'
                              : 'Apply to ${_startup?.companyName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          roleTitle != null
                              ? 'Tell the team why you are a fit for $roleTitle.'
                              : 'Write a brief message to introduce yourself.',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (roleTitle != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _startup?.companyName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: roleTitle != null
                      ? 'Why are you excited about $roleTitle?'
                      : 'Why are you interested in this opportunity?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                ),
              ),
              const SizedBox(height: 20),
              XPButton(
                label: 'Send Application',
                icon: Icons.send_rounded,
                onPressed: () async {
                  final appState = AppStateScope.of(context);
                  final student = appState.studentProfile;

                  if (student != null && _startup != null) {
                    final application = Application(
                      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
                      studentId: student.id,
                      startupId: _startup!.id,
                      studentName: student.name,
                      startupName: _startup!.companyName,
                      roleTitle: roleTitle,
                      status: ApplicationStatus.pending,
                      message: _messageController.text.isNotEmpty
                          ? _messageController.text
                          : null,
                      appliedAt: DateTime.now(),
                    );
                    await appState.addApplication(application);
                    setState(() {
                      if (roleTitle != null) {
                        _appliedRoleTitles.add(roleTitle);
                      } else {
                        _hasApplied = true;
                      }
                    });
                    _messageController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          roleTitle != null
                              ? 'Applied for $roleTitle at ${_startup!.companyName}!'
                              : 'Applied to ${_startup!.companyName}!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startup = _startup;
    final appState = AppStateScope.of(context);
    final studentSkills = appState.studentProfile?.skills ?? [];

    if (startup == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(Icons.arrow_back, color: AppTheme.text),
            ),
          ),
          title: const Text('Not Found'),
        ),
        body: const Center(child: Text('Startup not found')),
      );
    }

    final matchingSkills = startup.requiredSkills
        .where((skill) => studentSkills.contains(skill))
        .toList();
    StartupRole? nextRoleToApply;
    for (final role in startup.openRoles) {
      if (!_appliedRoleTitles.contains(role.title)) {
        nextRoleToApply = role;
        break;
      }
    }
    final roleCta = nextRoleToApply;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.softShadow,
            ),
            child: const Icon(Icons.arrow_back, color: AppTheme.text),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              startup.companyName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppTheme.text,
              ),
            ),
            Text(
              startup.industry,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card with Company Info
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: XPCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primary,
                                AppTheme.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              startup.companyName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                startup.companyName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
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
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  startup.industry,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
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
                        height: 1.6,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (startup.websiteUrl != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              startup.websiteUrl!,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skill Match Card
            if (matchingSkills.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.success.withValues(alpha: 0.15),
                      AppTheme.success.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.3),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.successDark.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppTheme.successDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Great match!',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.successDark,
                            ),
                          ),
                          Text(
                            'You have ${matchingSkills.length} matching skill${matchingSkills.length > 1 ? 's' : ''}: ${matchingSkills.join(", ")}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Open Roles Section
            if (startup.openRoles.isNotEmpty) ...[
              const XPSectionTitle(title: 'Open Roles'),
              const SizedBox(height: 10),
              Column(
                children: startup.openRoles.map((role) {
                  final alreadyApplied = _appliedRoleTitles.contains(role.title);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: XPCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.work_outline,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppTheme.text,
                                      ),
                                    ),
                                    if (role.commitment != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        role.commitment!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: alreadyApplied
                                      ? AppTheme.success.withValues(alpha: 0.1)
                                      : AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextButton.icon(
                                  onPressed: alreadyApplied
                                      ? null
                                      : () => _showApplyDialog(context, role: role),
                                  icon: Icon(
                                    alreadyApplied ? Icons.check_circle : Icons.send_rounded,
                                    color: alreadyApplied ? AppTheme.successDark : AppTheme.primary,
                                    size: 18,
                                  ),
                                  label: Text(
                                    alreadyApplied ? 'Applied' : 'Apply',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: alreadyApplied ? AppTheme.successDark : AppTheme.primary,
                                    ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (role.learningOutcome.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              role.learningOutcome,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                          Row(
                            children: [
                              if (role.estimatedHours != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 8, right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBackground,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${role.estimatedHours} hrs',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (role.durationWeeks != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBackground,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${role.durationWeeks} wks',
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
                          if (role.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                role.description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Skills Section
            const XPSectionTitle(title: 'Skills They Need'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: startup.requiredSkills.map((skill) {
                final isMatch = studentSkills.contains(skill);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isMatch
                        ? LinearGradient(
                            colors: [
                              AppTheme.success.withValues(alpha: 0.2),
                              AppTheme.success.withValues(alpha: 0.1),
                            ],
                          )
                        : null,
                    color: isMatch ? null : AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: isMatch
                        ? Border.all(color: AppTheme.success.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMatch) ...[
                        const Icon(Icons.check, size: 16, color: AppTheme.successDark),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        skill,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isMatch ? AppTheme.successDark : AppTheme.text,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Project Details Section
            if (startup.projectDetails != null) ...[
              const SizedBox(height: 20),
              const XPSectionTitle(title: "What They're Looking For"),
              const SizedBox(height: 10),
              XPCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  startup.projectDetails!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppTheme.text.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: XPButton(
            label: startup.openRoles.isNotEmpty
                ? (roleCta != null ? 'Apply for ${roleCta.title}' : 'Applications Sent')
                : (_hasApplied ? 'Application Sent!' : 'Apply Now'),
            icon: startup.openRoles.isNotEmpty
                ? (roleCta != null ? Icons.work_outline : Icons.check_circle)
                : (_hasApplied ? Icons.check_circle : Icons.send_rounded),
            onPressed: startup.openRoles.isNotEmpty
                ? (roleCta != null ? () => _showApplyDialog(context, role: roleCta) : null)
                : (_hasApplied ? null : () => _showApplyDialog(context)),
          ),
        ),
      ),
    );
  }
}
