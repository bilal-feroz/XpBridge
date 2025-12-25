import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../models/startup_role.dart';
import '../../models/startup_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_card.dart';

class StartupProfileScreen extends StatelessWidget {
  const StartupProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    final appState = AppStateScope.of(context);
    appState.logout();
    context.goNamed('login');
  }

  Future<void> _persistRoles(List<StartupRole> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'startup_roles',
      jsonEncode(roles.map((r) => r.toMap()).toList()),
    );
  }

  void _showAddRoleSheet(
    BuildContext context,
    AppState appState,
    StartupProfile? profile,
  ) {
    final titleController = TextEditingController();
    final commitmentController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 10,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 12),
                  const Text(
                    'Add a role',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Role title',
                      hintText: 'e.g. Software Engineer Intern',
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commitmentController,
                    decoration: InputDecoration(
                      labelText: 'Commitment (optional)',
                      hintText: '10 hrs/week • Remote',
                      prefixIcon: const Icon(Icons.schedule),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'What will the student work on?',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.description_outlined),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty || profile == null) return;

                        final role = StartupRole(
                          title: title,
                          commitment: commitmentController.text.trim().isNotEmpty
                              ? commitmentController.text.trim()
                              : null,
                          description: descriptionController.text.trim().isNotEmpty
                              ? descriptionController.text.trim()
                              : null,
                        );

                        final updated = profile.copyWith(
                          openRoles: [...profile.openRoles, role],
                        );
                        appState.saveStartupProfile(updated);
                        await _persistRoles(updated.openRoles);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${role.title}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add role'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final profile = appState.startupProfile;

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
        ),
        title: const Text(
          'Company Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Company Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  profile?.companyName.isNotEmpty == true
                      ? profile!.companyName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile?.companyName ?? 'Company',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile?.industry ?? 'Industry',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Section
            XPCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.business, size: 20, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'About Company',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.description ?? 'No description',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Project Details Section
            if (profile?.projectDetails != null) ...[
              XPCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.work_outline, size: 20, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Project Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile!.projectDetails!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Required Skills Section
            if (profile?.requiredSkills.isNotEmpty == true) ...[
              XPCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star_outline, size: 20, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Looking For Skills',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile!.requiredSkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Open Roles Section
            XPCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign_outlined, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Open Roles',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: profile == null
                            ? null
                            : () => _showAddRoleSheet(context, appState, profile),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (profile?.openRoles.isNotEmpty == true)
                    Column(
                      children: profile!.openRoles.map((role) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        role.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (role.commitment != null)
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
                                          role.commitment!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (role.description?.isNotEmpty == true) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    role.description!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Colors.black.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      'Add a role to let students apply directly.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact Section
            XPCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.email_outlined, size: 20, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Contact',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                  if (profile?.websiteUrl != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          size: 16,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile!.websiteUrl!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
