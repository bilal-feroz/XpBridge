import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/student_profile.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/xp_card.dart';

class StartupAiChatScreen extends StatefulWidget {
  const StartupAiChatScreen({super.key});

  @override
  State<StartupAiChatScreen> createState() => _StartupAiChatScreenState();
}

class _StartupAiChatScreenState extends State<StartupAiChatScreen> {
  // Constants
  static const _welcomeMessage =
    "Hey! 👋 I'm your AI talent finder. Tell me about what you're building or what skills you need - I'll help you find the perfect student match!\n\n"
    "You can chat naturally with me, like:\n"
    "• \"I'm building a mobile app\"\n"
    "• \"Need help with my website\"\n"
    "• \"Looking for someone who knows Python\"";

  static const _resetMessage = "Chat reset! Tell me what kind of student you're looking for.";

  // Controllers
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // State
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  List<StudentProfile> _matchedStudents = [];
  List<String> _searchedSkills = [];

  @override
  void initState() {
    super.initState();
    AiService.resetStartupChat();
    _addBotMessage(_welcomeMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() => _messages.add(_ChatMessage(text: text, isUser: false)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await AiService.sendMessageForStartup(text, null);
      setState(() {
        _isLoading = false;
        if (AiService.lastMatchedStudents.isNotEmpty) {
          _matchedStudents = AiService.lastMatchedStudents;
          _searchedSkills = [];
        }
      });
      _addBotMessage(response);
    } catch (e) {
      setState(() => _isLoading = false);
      _addBotMessage("⚠️ Error: $e");
    }
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _matchedStudents.clear();
    });
    AiService.resetStartupChat();
    _addBotMessage(_resetMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildChatList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.primary),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Talent Finder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text('Find the perfect student match', style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.normal)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _resetChat,
          tooltip: 'Reset chat',
        ),
      ],
    );
  }

  Widget _buildChatList() {
    final itemCount = _messages.length +
        (_matchedStudents.isNotEmpty ? 1 : 0) +
        (_isLoading ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _messages.length) {
          return _MessageBubble(message: _messages[index]);
        }
        if (_isLoading && index == _messages.length) {
          return const _TypingIndicator();
        }
        return _StudentResults(
          students: _matchedStudents,
          searchedSkills: _searchedSkills,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Describe the talent you need...',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.cardBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          _SendButton(isLoading: _isLoading, onPressed: _sendMessage),
        ],
      ),
    );
  }
}

// Private widgets
class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : AppTheme.text,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Padding(
            padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
            child: _AnimatedDot(delay: i * 200),
          )),
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final int delay;
  const _AnimatedDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.3 + (value * 0.5)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _SendButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send_rounded, color: Colors.white),
      ),
    );
  }
}

class _StudentResults extends StatelessWidget {
  final List<StudentProfile> students;
  final List<String> searchedSkills;
  const _StudentResults({required this.students, required this.searchedSkills});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Matching Students',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textSecondary),
          ),
        ),
        ...students.map((s) => _StudentCard(student: s, searchedSkills: searchedSkills)),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentProfile student;
  final List<String> searchedSkills;
  const _StudentCard({required this.student, required this.searchedSkills});

  @override
  Widget build(BuildContext context) {
    final matchedSkills = student.skills.where((skill) =>
      searchedSkills.any((s) => skill.toLowerCase().contains(s.toLowerCase()))
    ).toList();

    final displaySkills = searchedSkills.isNotEmpty
        ? [...matchedSkills, ...student.skills.where((s) => !matchedSkills.contains(s))]
        : student.skills;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: XPCard(
        padding: const EdgeInsets.all(12),
        elevated: true,
        onTap: () => context.pushNamed('studentDetail', pathParameters: {'id': student.id}),
        child: Row(
          children: [
            _Avatar(name: student.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      _Badge(
                        icon: Icons.schedule,
                        text: '${student.availabilityHours}h/wk',
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      _Badge(
                        icon: Icons.star,
                        text: '${student.xpPoints}',
                        color: AppTheme.successDark,
                        backgroundColor: AppTheme.success.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _SkillChips(skills: displaySkills.take(4).toList(), matchedSkills: matchedSkills),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withValues(alpha: 0.2), AppTheme.primary.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primary),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color? backgroundColor;
  const _Badge({required this.icon, required this.text, required this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _SkillChips extends StatelessWidget {
  final List<String> skills;
  final List<String> matchedSkills;
  const _SkillChips({required this.skills, required this.matchedSkills});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: skills.map((skill) {
        final isMatched = matchedSkills.contains(skill);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isMatched ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(6),
            border: isMatched ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3)) : null,
          ),
          child: Text(
            skill,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isMatched ? FontWeight.w600 : FontWeight.w500,
              color: isMatched ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
