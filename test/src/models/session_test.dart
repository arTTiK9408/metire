import 'package:test/test.dart';
import 'package:metire/src/models/session.dart';

void main() {
  group('session -', () {
    late Session s;
    setUp(() {
      s = Session(name: 'estudo');
    });

    test('name deve ser o valor passado no construtor', () {
      expect(s.name, equals('estudo'));
    });
    test('focusCount deve ser 0 ao iniciar', () {
      expect(s.focusCount, equals(0));
    });
    test('pauseCount deve ser 0 ao iniciar', () {
      expect(s.pauseCount, equals(0));
    });
    test('isActive deve ser false ao iniciar', () {
      expect(s.isActive, isFalse);
    });
    test('startTime deve ser definido ao criar', () {
      expect(s.startTime, isNotNull);
    });

    test('rename() deve alterar o nome', () {
      s.rename('trabalho');
      expect(s.name, equals('trabalho'));
    });

    test('registerFocus() deve incrementar focusCount', () {
      s.registerFocus();
      expect(s.focusCount, equals(1));
    });
    test('registerPause() deve incrementar pauseCount', () {
      s.registerPause();
      expect(s.pauseCount, equals(1));
    });
    test('registerFocus() é acumulativo', () {
      s.registerFocus();
      s.registerFocus();
      s.registerFocus();
      expect(s.focusCount, equals(3));
    });
    test('registerPause() é acumulativo', () {
      s.registerPause();
      s.registerPause();
      expect(s.pauseCount, equals(2));
    });

    test('begin() deve definir isActive como true', () {
      s.begin();
      expect(s.isActive, isTrue);
    });
    test('end() deve definir isActive como false', () {
      s.begin();
      s.end();
      expect(s.isActive, isFalse);
    });
    test('end() não lança erro se sessão não iniciada', () {
      s.end();
      expect(s.isActive, isFalse);
    });
    test('begin() é idempotente', () {
      s.begin();
      s.begin();
      expect(s.isActive, isTrue);
    });

    test('registerFocus() e registerPause() são independentes', () {
      s.registerPause();
      s.registerFocus();
      s.registerPause();
      s.registerFocus();
      expect(s.focusCount, equals(2));
      expect(s.pauseCount, equals(2));
    });

    test('end() preserva focusCount e pauseCount', () {
      s.registerFocus();
      s.registerFocus();
      s.registerPause();
      s.begin();
      s.end();
      expect(s.focusCount, equals(2));
      expect(s.pauseCount, equals(1));
      expect(s.isActive, isFalse);
    });

    test('end() é idempotente', () {
      s.begin();
      s.end();
      s.end();
      expect(s.isActive, isFalse);
    });

    test('startTime não muda após begin() e end()', () {
      final inicio = s.startTime;
      s.begin();
      s.end();
      expect(s.startTime, equals(inicio));
    });

    test('rename() com string vazia usa nome padrão "Unnamed Session"', () {
      s.rename('');
      expect(s.name, equals('Unnamed Session'));
    });
  });
}
