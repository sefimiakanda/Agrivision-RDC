import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._service);

  final GeminiService _service;
  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<bool> send(String question) async {
    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty || _isSending) {
      return false;
    }

    _messages.add(
      ChatMessage(
        text: normalizedQuestion,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final history = _messages
          .take(6)
          .map(
            (message) =>
                '${message.isUser ? 'Agriculteur' : 'Assistant'}: ${message.text}',
          )
          .toList(growable: false);
      final answer = await _service.ask(
        question: normalizedQuestion,
        previousMessages: history,
      );
      _messages.add(
        ChatMessage(text: answer, isUser: false, timestamp: DateTime.now()),
      );
      return true;
    } on GeminiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Impossible d’obtenir une réponse.';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
