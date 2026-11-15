import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rick_morty_explorer/models/character.dart';
import 'package:rick_morty_explorer/screens/auth_screen.dart';

void main() {
  testWidgets('login screen can switch to registration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AuthScreen(onLogin: () {})),
    );

    expect(find.text('CHARACTER EXPLORER'), findsOneWidget);
    await tester.tap(find.text('Belum punya akun? Register'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Akun'), findsOneWidget);
    expect(find.text('DAFTAR'), findsOneWidget);
  });

  test('character reads fields from the API response', () {
    final character = Character.fromJson({
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'gender': 'Male',
      'origin': {'name': 'Earth'},
      'location': {'name': 'Citadel of Ricks'},
      'image': 'https://example.com/rick.png',
    });

    expect(character.name, 'Rick Sanchez');
    expect(character.origin, 'Earth');
    expect(character.location, 'Citadel of Ricks');
  });
}
