import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiService {
  GeminiService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;
  static const _baseUrl = 'generativelanguage.googleapis.com';
  static const _model = 'gemini-2.0-flash';

  Future<String> ask({
    required String question,
    List<String> previousMessages = const [],
  }) async {
    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty) {
      throw const GeminiException('Écrivez une question avant de l’envoyer.');
    }
    if (apiKey.trim().isEmpty) {
      throw const GeminiException(
        'La clé Gemini est absente. Lancez l’application avec --dart-define=GEMINI_API_KEY=votre_cle.',
      );
    }

    final context = previousMessages.isEmpty
        ? ''
        : '\nHistorique récent :\n${previousMessages.join('\n')}';
    final prompt = '''Tu es l’assistant agricole d’Agrivision RDC.
Réponds en français simple, avec des conseils prudents et adaptés aux petits exploitants de la République Démocratique du Congo.
Ne prétends pas remplacer un agronome. Pour les produits phytosanitaires, recommande de respecter l’étiquette et de demander conseil à un technicien local.
Question de l’agriculteur : $normalizedQuestion$context''';

    try {
      final response = await _client
          .post(
            Uri.https(_baseUrl, '/v1beta/models/$_model:generateContent', {
              'key': apiKey,
            }),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 500},
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403) {
        final message = _extractApiError(response.body);
        throw GeminiException(
          message ?? 'La clé Gemini est invalide ou refusée.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const GeminiException(
          'Gemini est momentanément indisponible. Réessayez plus tard.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>? ?? const [];
      final firstCandidate = candidates.firstOrNull as Map<String, dynamic>?;
      final content = firstCandidate?['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>? ?? const [];
      final text = parts.firstOrNull is Map<String, dynamic>
          ? (parts.first as Map<String, dynamic>)['text'] as String?
          : null;
      if (text == null || text.trim().isEmpty) {
        throw const GeminiException('Gemini n’a pas renvoyé de réponse.');
      }
      return text.trim();
    } on GeminiException {
      rethrow;
    } on http.ClientException {
      throw const GeminiException(
        'Connexion impossible. Vérifiez votre accès Internet.',
      );
    } on FormatException {
      throw const GeminiException('La réponse de Gemini est invalide.');
    } catch (_) {
      throw const GeminiException(
        'L’assistant est momentanément indisponible. Réessayez plus tard.',
      );
    }
  }

  String? _extractApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final error = decoded['error'];
      if (error is! Map<String, dynamic>) {
        return null;
      }
      final message = error['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
