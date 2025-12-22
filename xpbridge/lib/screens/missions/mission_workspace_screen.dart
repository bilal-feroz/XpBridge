import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/mission.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_app_bar.dart';
import '../../widgets/xp_button.dart';
import '../../widgets/xp_card.dart';
import '../../widgets/xp_section_title.dart';

class MissionWorkspaceScreen extends StatefulWidget {
  const MissionWorkspaceScreen({super.key, required this.mission});

  final Mission mission;

  @override
  State<MissionWorkspaceScreen> createState() => _MissionWorkspaceScreenState();
}

class _MissionWorkspaceScreenState extends State<MissionWorkspaceScreen> {
  bool fileAttached = false;
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: XPAppBar(title: 'Workspace', subtitle: widget.mission.title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XPCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Accept mission'),
                        const Spacer(),
                        Container(
                          width: 46,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 46,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          fileAttached
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: fileAttached ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(fileAttached ? 'File attached' : 'Upload file'),
                        const Spacer(),
                        Container(
                          width: 46,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: fileAttached ? 46 : 18,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          notes.isNotEmpty
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: notes.isNotEmpty ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('Add notes'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const XPSectionTitle(title: '1. Upload your file'),
              const SizedBox(height: 10),
              XPCard(
                onTap: () => setState(() => fileAttached = true),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        fileAttached
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_upload_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileAttached
                                ? 'design_explainer.fig attached'
                                : 'Click to mock upload',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For web, we simulate an upload. Marked as attached.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const XPSectionTitle(title: '2. Add notes'),
              const SizedBox(height: 10),
              XPCard(
                child: TextField(
                  maxLines: 5,
                  onChanged: (v) => setState(() => notes = v),
                  decoration: const InputDecoration(
                    hintText:
                        'What did you focus on? Any blockers or decisions?',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const XPSectionTitle(title: '3. Submit'),
              const SizedBox(height: 10),
              XPButton(
                label: 'Submit work',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  context.pushNamed(
                    'submissionSuccess',
                    extra: {'mission': widget.mission, 'xp': widget.mission.xp},
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Ensure deliverables match the checklist.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
