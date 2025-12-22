import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../data/dummy_data.dart';
import '../../models/mission.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_app_bar.dart';
import '../../widgets/xp_card.dart';

class MissionFeedScreen extends StatefulWidget {
  const MissionFeedScreen({super.key});

  @override
  State<MissionFeedScreen> createState() => _MissionFeedScreenState();
}

class _MissionFeedScreenState extends State<MissionFeedScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final missions = _filter == 'All'
        ? DummyData.missions
        : DummyData.missions
              .where(
                (m) => m.tags
                    .map((t) => t.toLowerCase())
                    .contains(_filter.toLowerCase()),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: XPAppBar(
        showBack: false,
        title: 'XPBridge',
        subtitle: appState.profile != null
            ? '${appState.profile!.track} - ${appState.profile!.skills.take(3).join(', ')}'
            : 'Earn real experience before graduation',
        trailing: IconButton(
          onPressed: () => context.goNamed('skillsPassport'),
          icon: const Icon(Icons.workspace_premium_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              XPCard(
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
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily missions just for you',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appState.isTeen
                                ? 'Curated for 15-17 with safety rails.'
                                : 'Higher stakes projects unlocked.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.black.withValues(alpha: 0.65),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    const SizedBox(width: 2),
                    ...['All', ...DummyData.tracks].map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: _filter == tag,
                          onSelected: (_) => setState(() => _filter = tag),
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: _filter == tag
                                ? Colors.white
                                : AppTheme.text,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: _filter == tag
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: missions.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) => _MissionCard(
                    mission: missions[index],
                    isTeen: appState.isTeen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.isTeen});

  final Mission mission;
  final bool isTeen;

  @override
  Widget build(BuildContext context) {
    return XPCard(
      onTap: () => context.pushNamed(
        'missionDetails',
        pathParameters: {'id': mission.id},
        extra: mission,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mission.startupName,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  mission.reward,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18),
              const SizedBox(width: 6),
              Text(mission.timeEstimate),
              const Spacer(),
              Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amber.shade700,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('+${mission.xp} XP'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mission.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                mission.safeForTeens
                    ? Icons.verified_rounded
                    : Icons.shield_outlined,
                color: mission.safeForTeens
                    ? Colors.green
                    : Colors.orange.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                mission.safeForTeens
                    ? 'Safe for 15-17'
                    : isTeen
                    ? 'Adult-only mission'
                    : 'Advanced mission',
                style: TextStyle(
                  color: mission.safeForTeens
                      ? Colors.green.shade700
                      : isTeen
                      ? Colors.orange.shade800
                      : Colors.black.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }
}
