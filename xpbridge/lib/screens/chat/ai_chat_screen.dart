import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app.dart';
import '../../models/ai_chat_message.dart';
import '../../services/ai_service.dart';
import '../../services/job_matcher_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/xp_card.dart';

enum AiState { idle, thinking, responding, error }

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
  AiState _aiState = AiState.idle;
  bool _showQuickActions = true;
  bool _sendButtonScale = false;

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

  Future<void> _sendMessage([String? predefinedText]) async {
    final text = predefinedText ?? _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final appState = AppStateScope.of(context);
    final profile = appState.studentProfile;

    // Hide quick actions after first message
    if (_showQuickActions) {
      setState(() => _showQuickActions = false);
    }

    // Add user message
    setState(() {
      _messages.add(AiChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _aiState = AiState.thinking;
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
      _aiState = AiState.responding;
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
        _aiState = AiState.idle;
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
        _aiState = AiState.error;
      });
      // Reset to idle after showing error
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _aiState = AiState.idle);
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
      _showQuickActions = true;
      _aiState = AiState.idle;
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
            _AiAvatar(state: _aiState),
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
                    itemCount: _messages.length +
                        (_showQuickActions && _messages.length == 1 ? 1 : 0) +
                        (_showMatchedRoles ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show quick actions after welcome message
                      if (_showQuickActions &&
                          _messages.length == 1 &&
                          index == 1) {
                        return _buildQuickActions();
                      }
                      // Adjust index if quick actions are shown
                      final messageIndex = _showQuickActions &&
                              _messages.length == 1 &&
                              index > 0
                          ? index - 1
                          : index;
                      // Show matched roles at the end
                      if (_showMatchedRoles && messageIndex == _messages.length) {
                        return _buildMatchedRolesSection();
                      }
                      return ChatBubble(message: _messages[messageIndex]);
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
              gradient: LinearGradient(
                colors: [
                  AppTheme.surface,
                  AppTheme.cardBackground.withValues(alpha: 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, -4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _messages.length <= 1
                              ? 'Ask about missions, skills, or your profile'
                              : 'Type your message...',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTapDown: (_) =>
                        setState(() => _sendButtonScale = true),
                    onTapUp: (_) {
                      setState(() => _sendButtonScale = false);
                      if (!_isLoading) _sendMessage();
                    },
                    onTapCancel: () =>
                        setState(() => _sendButtonScale = false),
                    child: AnimatedScale(
                      scale: _sendButtonScale ? 0.92 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: _isLoading
                              ? null
                              : LinearGradient(
                                  colors: [
                                    AppTheme.primary,
                                    AppTheme.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: _isLoading ? AppTheme.textMuted : null,
                          shape: BoxShape.circle,
                          boxShadow: _isLoading
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
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

  Widget _buildQuickActions() {
    final actions = [
      ('Find a mission for me', Icons.rocket_launch_rounded),
      ('Improve my profile', Icons.auto_awesome_rounded),
      ('What skills should I learn next?', Icons.psychology_rounded),
      ('Help me complete a mission', Icons.flag_rounded),
    ];

    return AnimatedOpacity(
      opacity: _showQuickActions ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Quick actions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _QuickActionChip(
                      label: action.$1,
                      icon: action.$2,
                      onTap: () => _sendMessage(action.$1),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16),
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.15),
                        AppTheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
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
                        match.role.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
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
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.success.withValues(alpha: 0.2),
                        AppTheme.success.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${(match.matchScore * 100).round()}% match',
                    style: TextStyle(
                      color: AppTheme.successDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.matchReason,
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (match.role.commitment != null) ...[
              const SizedBox(height: 10),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Suggested by XPBridge AI',
                    style: TextStyle(
                      color: AppTheme.primary.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/student/startup/${match.startup.id}');
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'View Mission',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// AI Avatar Widget with state-based animations
class _AiAvatar extends StatelessWidget {
  final AiState state;

  const _AiAvatar({required this.state});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: state == AiState.responding ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, shimmerValue, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: state == AiState.error
                  ? [
                      AppTheme.error.withValues(alpha: 0.15),
                      AppTheme.error.withValues(alpha: 0.05),
                    ]
                  : [
                      AppTheme.primary.withValues(alpha: 0.15),
                      AppTheme.primary.withValues(alpha: 0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (state == AiState.thinking || state == AiState.responding)
                BoxShadow(
                  color: AppTheme.primary.withValues(
                    alpha: 0.3 * (state == AiState.thinking ? 0.5 : shimmerValue),
                  ),
                  blurRadius: 12,
                  spreadRadius: state == AiState.responding ? 2 : 0,
                ),
            ],
          ),
          child: Stack(
            children: [
              Icon(
                Icons.auto_awesome,
                color: state == AiState.error
                    ? AppTheme.error
                    : AppTheme.primary,
                size: 22,
              ),
              if (state == AiState.error)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.background,
                        width: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Quick Action Chip Widget
class _QuickActionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.08),
                AppTheme.primary.withValues(alpha: 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
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
