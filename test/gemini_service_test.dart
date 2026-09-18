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

  test(
    'bascule vers un modèle compatible si le modèle principal est absent',
    () async {
      final client = FakeGeminiClient(failPrimaryModel: true);
      final service = GeminiService(apiKey: 'test-key', client: client);

      final answer = await service.ask(
        question: 'Comment protéger mes plants ?',
      );

      expect(answer, contains('Arrosez le matin'));
      expect(client.requestedModels, [
        'gemini-2.5-flash',
        'gemini-2.5-flash-lite',
        'gemini-2.0-flash',
      ]);
    },
  );
}

class FakeGeminiClient extends http.BaseClient {
  FakeGeminiClient({this.statusCode = 200, this.failPrimaryModel = false});

  final int statusCode;
  final bool failPrimaryModel;
  final requestedModels = <String>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final model = request.url.pathSegments[2].split(':').first;
    requestedModels.add(model);
    final primaryModelUnavailable =
        failPrimaryModel && model == 'gemini-2.5-flash';
    final responseStatus = primaryModelUnavailable ? 404 : statusCode;
    final body = primaryModelUnavailable
        ? jsonEncode({
            'error': {'message': 'Model gemini-2.5-flash not found'},
          })
        : responseStatus == 200
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
      responseStatus,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}
