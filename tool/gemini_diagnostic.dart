import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  stdout.writeln('API key present: ${apiKey != null && apiKey.isNotEmpty}');
  if (apiKey != null && apiKey.isNotEmpty) {
    stdout.writeln('API key prefix: ${apiKey.substring(0, 8)}...');
  }

  final models = [
    'gemini-3.6-flash',
    'gemini-2.5-pro',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];

  for (final modelName in models) {
    stdout.writeln('\n--- Testing model: $modelName ---');
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey!,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );
      final response = await model
          .generateContent([
            Content.text('Return JSON: {"ok": true}'),
          ])
          .timeout(const Duration(seconds: 30));
      stdout.writeln('SUCCESS: ${response.text}');
    } catch (e, st) {
      stdout.writeln('ERROR type: ${e.runtimeType}');
      stdout.writeln('ERROR: $e');
      stdout.writeln('STACK: $st');
    }
  }
}
