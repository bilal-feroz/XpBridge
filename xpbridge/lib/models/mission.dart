class Mission {
  final String id;
  final String title;
  final String startupName;
  final String timeEstimate;
  final String reward;
  final List<String> tags;
  final bool safeForTeens;
  final String summary;
  final List<String> deliverables;
  final List<String> safetyNotes;
  final int xp;

  const Mission({
    required this.id,
    required this.title,
    required this.startupName,
    required this.timeEstimate,
    required this.reward,
    required this.tags,
    required this.safeForTeens,
    required this.summary,
    required this.deliverables,
    required this.safetyNotes,
    required this.xp,
  });
}
