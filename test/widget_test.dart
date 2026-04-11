import 'package:flutter_test/flutter_test.dart';

import 'package:projeto_integrado_mobile/src/app/wireframe.dart';

void main() {
  test('Wireframe can be instantiated', () {
    const app = Wireframe();

    expect(app, isA<Wireframe>());
  });
}
