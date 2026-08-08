import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final env = File('.env').readAsLinesSync();
  final keyLine = env.firstWhere((l) => l.startsWith('GEMINI_API_KEY='));
  final key = keyLine.substring('GEMINI_API_KEY='.length).trim();

  final payload = {
    'patientProfile': {
      'age': 54,
      'sex': 'Female',
      'bmi': 29.1,
      'smokingStatus': 'Never Smoked',
      'alcoholConsumption': 'Occasionally',
    },
    'monitoring': {
      'fastingGlucose': 162,
      'randomGlucose': 231,
      'hba1c': 8.3,
      'bloodPressure': {'systolic': 148, 'diastolic': 94},
      'foodIntake': 'Rice',
      'exercise': 'Walking 30 min',
      'medicationAdherence': true,
      'notes': 'Tired',
      'recordedAt': '2026-07-31T08:30:00',
    },
    'history': [],
  };

  final prompt =
      'Return ONLY valid JSON with keys cdriScore, riskClassification, '
      'contributingFactors, recommendations, summary.\n'
      'Patient data:\n${jsonEncode(payload)}';

  final body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': prompt},
        ],
      },
    ],
    'generationConfig': {
      'temperature': 0.3,
      'responseMimeType': 'application/json',
    },
  });

  final client = HttpClient();
  final request = await client.postUrl(
    Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-3.6-flash:generateContent?key=$key',
    ),
  );
  request.headers.contentType = ContentType.json;
  request.write(body);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  stdout.writeln('STATUS: ${response.statusCode}');
  if (response.statusCode == 200) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final text =
        json['candidates'][0]['content']['parts'][0]['text'] as String;
    stdout.writeln('RESPONSE:\n$text');
    final parsed = jsonDecode(text) as Map<String, dynamic>;
    stdout.writeln('PARSED KEYS: ${parsed.keys.toList()}');
    stdout.writeln('RISK: ${parsed['riskClassification']}');
  } else {
    stdout.writeln(responseBody);
  }
  client.close();
}
