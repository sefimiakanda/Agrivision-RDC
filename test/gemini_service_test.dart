import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:agrivision_drc/services/gemini_service.dart';

void main() {
  test('retourne la réponse de Gemini', () async {
    final service = GeminiService(
      apiKey: 'test-key',
      client: FakeGeminiClient(),
    );

    final answer = await service.ask(question: 'Quand arroser le maïs ?');

    expect(answer, contains('Arrosez le matin'));
  });

  test('signale une clé Gemini refusée', () async {
    final service = GeminiService(
      apiKey: 'test-key',
      client: FakeGeminiClient(statusCode: 403),
    );

    expect(
      () => service.ask(question: 'Question agricole'),
      throwsA(
        isA<GeminiException>().having(
          (error) => error.message,
          'message',
          contains('invalide ou refusée'),
        ),
      ),
    );
  });
}

class FakeGeminiClient extends http.BaseClient {
  FakeGeminiClient({this.statusCode = 200});

  final int statusCode;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = statusCode == 200
        ? jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Arrosez le matin, lorsque le sol est sec.'},
                  ],
                },
              },
            ],
          })
        : '{}';
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      statusCode,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}
