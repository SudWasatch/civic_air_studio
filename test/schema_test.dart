import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  test('Verify Gemini 2.5 Flash schema compatibility', () {
    final schema = Schema.object(
      properties: {
        'summary': Schema.string(description: 'Summary'),
        'score': Schema.integer(description: 'Score'),
        'level': Schema.enumString(
          enumValues: ['Good', 'Bad'],
          description: 'Risk Level',
        ),
        'tags': Schema.array(items: Schema.string()),
        'nested': Schema.object(
          properties: {
            'active': Schema.boolean(),
            'rating': Schema.number(),
          },
          requiredProperties: ['active'],
        ),
      },
      requiredProperties: ['summary', 'score'],
    );
    expect(schema, isNotNull);
  });
}
