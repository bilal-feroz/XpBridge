import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app.dart';
import '../../models/ai_chat_message.dart';
import '../../services/ai_service.dart';
import '../../services/job_matcher_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/xp_card.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiChatMessage> _messages = [];
  List<MatchedRole> _matchedRoles = [];
  bool _isLoading = false;
  bool _showMatchedRoles = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final appState = AppStateScope.of(context);
    final profile = appState.studentProfile;

    // Add welcome message
    setState(() {
      _messages.add(AiChatMessage(
        id: 'welcome',
        content:
            "Hi${profile != null ? ' ${profile.name.split(' ').first}' : ''}! I'm your career advisor. Tell me about yourself - your education, skills, and what kind of work interests you. I'll help you find the perfect role!",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final appState = AppStateScope.of(context);
    final profile = appState.studentProfile;

    // Add user message
    setState(() {
      _messages.add(AiChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Add loading message
    final loadingId = 'loading_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.add(AiChatMessage(
        id: loadingId,
        content: '',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        isLoading: true,
      ));
    });
    _scrollToBottom();

    try {
      // Send message to AI
      final response = await AiService.sendMessageWithContext(text, profile);

      // Remove loading message and add real response
      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);
        _messages.add(AiChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response,
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      // Check if AI gave recommendations
      final recommendedRoles = AiService.extractRecommendedRoles(response);
      if (recommendedRoles.isNotEmpty) {
        // Find matching roles in the app
        final matches = JobMatcherService.findMatchingRoles(
          recommendedRoles,
          userSkills: profile?.skills,
        );

        if (matches.isNotEmpty) {
          setState(() {
            _matchedRoles = matches.take(5).toList();
            _showMatchedRoles = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);
        _messages.add(AiChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Error: $e',
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _resetChat() {
    AiService.resetChat();
    setState(() {
      _messages.clear();
      _matchedRoles.clear();
      _showMatchedRoles = false;
      _isInitialized = false;
    });
    _initializeChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Career Advisor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'AI-powered guidance',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _resetChat,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Start new chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _isInitialized
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        _messages.length + (_showMatchedRoles ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_showMatchedRoles && index == _messages.length) {
                        return _buildMatchedRolesSection();
                      }
                      return ChatBubble(message: _messages[index]);
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Tell me about yourself...',
                        filled: true,
                        fillColor: AppTheme.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? AppTheme.textMuted
                            : AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedRolesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Matching opportunities on XpBridge',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._matchedRoles.map((match) => _buildMatchedRoleCard(match)),
        ],
      ),
    );
  }

  Widget _buildMatchedRoleCard(MatchedRole match) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: XPCard(
        onTap: () {
          context.push('/student/startup/${match.startup.id}');
        },
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
                        match.role.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.startup.companyName,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(match.matchScore * 100).round()}% match',
                    style: TextStyle(
                      color: AppTheme.successDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (match.role.commitment != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    match.role.commitment!,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              match.matchReason,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
