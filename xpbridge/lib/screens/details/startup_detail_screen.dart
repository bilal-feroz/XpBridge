import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/application.dart';
import '../../models/startup_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_app_bar.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';

class StartupDetailScreen extends StatefulWidget {
  const StartupDetailScreen({super.key, required this.startupId});

  final String startupId;

  @override
  State<StartupDetailScreen> createState() => _StartupDetailScreenState();
}

class _StartupDetailScreenState extends State<StartupDetailScreen> {
  final _messageController = TextEditingController();
  bool _hasApplied = false;

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

  void _showApplyDialog(BuildContext context) {
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
              Text(
                'Apply to ${_startup?.companyName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Write a brief message to introduce yourself.',
                style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Why are you interested in this opportunity?',
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
                onPressed: () {
                  final appState = AppStateScope.of(context);
                  final student = appState.studentProfile;

                  if (student != null && _startup != null) {
                    final application = Application(
                      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
                      studentId: student.id,
                      startupId: _startup!.id,
                      studentName: student.name,
                      startupName: _startup!.companyName,
                      status: ApplicationStatus.pending,
                      message: _messageController.text.isNotEmpty
                          ? _messageController.text
                          : null,
                      appliedAt: DateTime.now(),
                    );
                    appState.addApplication(application);
                    setState(() => _hasApplied = true);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied to ${_startup!.companyName}!'),
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
        body: SafeArea(
          child: Column(
            children: [
              const XPAppBar(title: 'Not Found'),
              const Expanded(child: Center(child: Text('Startup not found'))),
            ],
          ),
        ),
      );
    }

    final matchingSkills = startup.requiredSkills
        .where((skill) => studentSkills.contains(skill))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            XPAppBar(title: startup.companyName, subtitle: startup.industry),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    XPCard(
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
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    startup.companyName[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
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
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
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
                              height: 1.5,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          if (startup.websiteUrl != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.link,
                                  size: 16,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  startup.websiteUrl!,
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (matchingSkills.isNotEmpty) ...[
                      XPCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
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
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'You have ${matchingSkills.length} matching skill${matchingSkills.length > 1 ? 's' : ''}: ${matchingSkills.join(", ")}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
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
                    const Text(
                      'Skills They Need',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: startup.requiredSkills.map((skill) {
                        final isMatch = studentSkills.contains(skill);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isMatch
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: isMatch
                                ? Border.all(
                                    color: Colors.green.withValues(alpha: 0.3),
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isMatch) ...[
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                skill,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isMatch
                                      ? Colors.green.shade700
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (startup.projectDetails != null) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'What They\'re Looking For',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      XPCard(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          startup.projectDetails!,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
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
          child: XPButton(
            label: _hasApplied ? 'Application Sent!' : 'Apply Now',
            icon: _hasApplied ? Icons.check_circle : Icons.send_rounded,
            onPressed: _hasApplied ? null : () => _showApplyDialog(context),
          ),
        ),
      ),
    );
  }
}
