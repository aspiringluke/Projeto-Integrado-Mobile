import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';

void main() {
  test('ContentStats counts words, characters, and mentions', () {
    final stats = ContentStats.fromText('Uma nota com @Personagem');

    expect(stats.words, 4);
    expect(stats.characters, greaterThan(0));
    expect(stats.mentions, 1);
  });
}
