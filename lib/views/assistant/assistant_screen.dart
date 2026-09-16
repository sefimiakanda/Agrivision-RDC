import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/chat_provider.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key, required this.service});

  final GeminiService service;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(service),
      child: const _AssistantView(),
    );
  }
}

class _AssistantView extends StatefulWidget {
  const _AssistantView();

  @override
  State<_AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<_AssistantView> {
  final _questionController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant agricole')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.messages.isEmpty) {
                  return const _AssistantEmptyState();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  itemCount:
                      provider.messages.length + (provider.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(message: provider.messages[index]);
                  },
                );
              },
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      if (provider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Color(0xFFB86B18)),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _questionController,
                              minLines: 1,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                hintText: 'Ex. Quand arroser mon maïs ?',
                                prefixIcon: Icon(Icons.help_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: provider.isSending ? null : _send,
                            tooltip: 'Envoyer la question',
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final question = _questionController.text;
    if (question.trim().isEmpty) {
      return;
    }
    _questionController.clear();
    final sent = await context.read<ChatProvider>().send(question);
    if (!mounted) {
      return;
    }
    if (sent) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }
}

class _AssistantEmptyState extends StatelessWidget {
  const _AssistantEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology_outlined,
              size: 70,
              color: Color(0xFF4D4B91),
            ),
            const SizedBox(height: 18),
            Text(
              'Votre assistant agricole',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF17352B),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Posez une question sur vos cultures, l’arrosage, les traitements ou la météo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF63746B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final color = message.isUser ? const Color(0xFF176B4D) : Colors.white;
    final textColor = message.isUser ? Colors.white : const Color(0xFF17352B);
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isUser ? 18 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 18),
          ),
          border: message.isUser
              ? null
              : Border.all(color: const Color(0xFFE3EAE3)),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor, height: 1.4),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text(
          'Assistant en train de répondre...',
          style: TextStyle(color: Color(0xFF63746B)),
        ),
      ),
    );
  }
}
