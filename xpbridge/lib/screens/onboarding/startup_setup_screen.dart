import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/startup_profile.dart';
import '../../models/startup_role.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';
import '../../widgets/xp_chip.dart';
import '../../widgets/xp_section_title.dart';

class StartupSetupScreen extends StatefulWidget {
  const StartupSetupScreen({super.key});

  @override
  State<StartupSetupScreen> createState() => _StartupSetupScreenState();
}

class _StartupSetupScreenState extends State<StartupSetupScreen> {
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectDetailsController = TextEditingController();
  final _websiteController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _roleCommitmentController = TextEditingController();
  final _roleDescriptionController = TextEditingController();
  final _roleOutcomeController = TextEditingController();
  final _roleHoursController = TextEditingController();
  final _roleDurationController = TextEditingController();
  String? _selectedIndustry;
  final Set<String> _requiredSkills = {};
  final List<StartupRole> _openRoles = [];

  @override
  void initState() {
    super.initState();
    _selectedIndustry = DummyData.industries.first;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _projectDetailsController.dispose();
    _websiteController.dispose();
    _roleTitleController.dispose();
    _roleCommitmentController.dispose();
    _roleDescriptionController.dispose();
    _roleOutcomeController.dispose();
    _roleHoursController.dispose();
    _roleDurationController.dispose();
    super.dispose();
  }

  void _addRole() {
    final title = _roleTitleController.text.trim();
    final commitment = _roleCommitmentController.text.trim();
    final description = _roleDescriptionController.text.trim();
    final outcome = _roleOutcomeController.text.trim();
    final estimatedHours = int.tryParse(_roleHoursController.text.trim());
    final durationWeeks = int.tryParse(_roleDurationController.text.trim());

    if (title.isEmpty || outcome.isEmpty) {
      return;
    }

    final role = StartupRole(
      title: title,
      commitment: commitment.isNotEmpty ? commitment : null,
      description: description.isNotEmpty ? description : null,
      learningOutcome: outcome,
      estimatedHours: estimatedHours,
      durationWeeks: durationWeeks,
    );

    setState(() {
      _openRoles.add(role);
      _roleTitleController.clear();
      _roleCommitmentController.clear();
      _roleDescriptionController.clear();
      _roleOutcomeController.clear();
      _roleHoursController.clear();
      _roleDurationController.clear();
    });
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
                      Icons.business,
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
                          'Set up your company',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Help students learn about you',
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
                      const XPSectionTitle(title: 'Company Info'),
                      const SizedBox(height: 10),
                      XPCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _companyNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                hintText: 'Enter your company name',
                                prefixIcon: const Icon(Icons.business),
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
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Company Description',
                                hintText: 'What does your company do?',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 48),
                                  child: Icon(Icons.description_outlined),
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
                              controller: _websiteController,
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: 'Website (optional)',
                                hintText: 'https://yourcompany.com',
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
                      const XPSectionTitle(title: 'Industry'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: DummyData.industries
                            .map(
                              (industry) => XPChoiceChip(
                                label: industry,
                                selected: _selectedIndustry == industry,
                                onSelected: (_) => setState(
                                  () => _selectedIndustry = industry,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      const XPSectionTitle(
                        title: 'Skills you need (select 2-4)',
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: DummyData.skillPool
                            .map(
                              (skill) => XPChoiceChip(
                                label: skill,
                                selected: _requiredSkills.contains(skill),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (_requiredSkills.length < 4) {
                                        _requiredSkills.add(skill);
                                      }
                                    } else {
                                      _requiredSkills.remove(skill);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      const XPSectionTitle(title: 'Project Details'),
                      const SizedBox(height: 10),
                      XPCard(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _projectDetailsController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'What are you looking for?',
                            hintText:
                                'Describe the projects or roles you need help with...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.cardBackground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const XPSectionTitle(title: 'Open Roles (optional)'),
                      const SizedBox(height: 10),
                      XPCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _roleTitleController,
                              decoration: InputDecoration(
                                labelText: 'Role title',
                                hintText: 'e.g. Product Design Intern',
                                prefixIcon: const Icon(Icons.work_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.cardBackground,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _roleCommitmentController,
                              decoration: InputDecoration(
                                labelText: 'Commitment (optional)',
                                hintText: '10-12 hrs/week • Remote',
                                prefixIcon: const Icon(Icons.schedule),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.cardBackground,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _roleDescriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'What will they do? (optional)',
                                hintText:
                                    'Briefly describe the responsibilities or outcomes.',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 48),
                                  child: Icon(Icons.description_outlined),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              filled: true,
                              fillColor: AppTheme.cardBackground,
                            ),
                          ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _roleOutcomeController,
                              decoration: InputDecoration(
                                labelText: 'Learning outcome (required)',
                                hintText: 'What will the student achieve?',
                                prefixIcon: const Icon(Icons.flag_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.cardBackground,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _roleHoursController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Estimated hours',
                                      prefixIcon: const Icon(Icons.timer_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.cardBackground,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _roleDurationController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Duration (weeks)',
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.cardBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.primaryDark],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _addRole,
                                  icon: const Icon(Icons.add),
                                  label: const Text(
                                    'Add role',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_openRoles.isEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
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
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'List the roles you want students to apply to.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_openRoles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Column(
                          children: _openRoles.map((role) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primary.withValues(alpha: 0.06),
                                      AppTheme.primary.withValues(alpha: 0.02),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: XPCard(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.work_outline,
                                              size: 16,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              role.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.text,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _openRoles.removeWhere(
                                                  (r) => r.title == role.title,
                                                );
                                              });
                                            },
                                            icon: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppTheme.error.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: AppTheme.error,
                                                size: 16,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (role.commitment != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        role.commitment!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.successDark,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                            borderRadius: BorderRadius.circular(8),
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
                                                  fontWeight: FontWeight.w600,
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
                                            borderRadius: BorderRadius.circular(8),
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
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (role.description?.isNotEmpty == true) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      role.description!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.5,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 22),
                      const XPSectionTitle(title: 'Preview'),
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
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppTheme.primary, AppTheme.primaryDark],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
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
                                        _companyNameController.text.isNotEmpty
                                            ? _companyNameController.text[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontSize: 24,
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
                                          _companyNameController.text.isNotEmpty
                                              ? _companyNameController.text
                                              : 'Company Name',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: AppTheme.text,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
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
                                            _selectedIndustry ?? 'Industry',
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
                              if (_descriptionController.text.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _descriptionController.text,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Text(
                                'Looking for:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (_requiredSkills.isEmpty
                                        ? ['Select skills']
                                        : _requiredSkills)
                                    .map(
                                      (skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: _requiredSkills.isNotEmpty
                                              ? LinearGradient(
                                                  colors: [
                                                    AppTheme.primary.withValues(alpha: 0.15),
                                                    AppTheme.primary.withValues(alpha: 0.08),
                                                  ],
                                                )
                                              : null,
                                          color: _requiredSkills.isEmpty
                                              ? AppTheme.cardBackground
                                              : null,
                                          borderRadius: BorderRadius.circular(10),
                                          border: _requiredSkills.isNotEmpty
                                              ? Border.all(
                                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                                )
                                              : null,
                                        ),
                                        child: Text(
                                          skill,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: _requiredSkills.isNotEmpty
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
                    (_companyNameController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty &&
                        _requiredSkills.length >= 2)
                    ? () async {
                        final prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString('user_email') ?? '';

                        final profile = StartupProfile(
                          id: 'startup_${DateTime.now().millisecondsSinceEpoch}',
                          companyName: _companyNameController.text,
                          email: email,
                          description: _descriptionController.text,
                          industry: _selectedIndustry!,
                          requiredSkills: _requiredSkills.toList(),
                          openRoles: _openRoles.toList(),
                          websiteUrl: _websiteController.text.isNotEmpty
                              ? _websiteController.text
                              : null,
                          projectDetails:
                              _projectDetailsController.text.isNotEmpty
                              ? _projectDetailsController.text
                              : null,
                          createdAt: DateTime.now(),
                        );

                        // Save profile data to shared_preferences
                        await prefs.setString('startup_name', _companyNameController.text);
                        await prefs.setString('startup_description', _descriptionController.text);
                        await prefs.setString('startup_industry', _selectedIndustry!);
                        await prefs.setStringList('startup_skills', _requiredSkills.toList());
                        await prefs.setString('startup_project', _projectDetailsController.text);
                        await prefs.setString(
                          'startup_roles',
                          jsonEncode(
                            _openRoles.map((role) => role.toMap()).toList(),
                          ),
                        );

                        if (!context.mounted) return;
                        appState.saveStartupProfile(profile);
                        context.goNamed('startupDashboard');
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
