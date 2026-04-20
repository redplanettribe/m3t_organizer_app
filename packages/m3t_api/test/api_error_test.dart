import 'package:m3t_api/src/models/api_error.dart';
import 'package:test/test.dart';

void main() {
  group('ApiError', () {
    test('parses code, message, and show_to_user from JSON', () {
      final error = ApiError.fromJson(const <String, dynamic>{
        'code': 'session_full',
        'message': 'Session is at capacity',
        'show_to_user': true,
      });

      expect(error.code, 'session_full');
      expect(error.message, 'Session is at capacity');
      expect(error.showToUser, isTrue);
    });

    test('defaults show_to_user to false when missing', () {
      final error = ApiError.fromJson(const <String, dynamic>{
        'code': 'internal_error',
        'message': 'Something went wrong',
      });

      expect(error.showToUser, isFalse);
    });

    test('serializes show_to_user back to snake_case', () {
      const error = ApiError(
        code: 'schedule_conflict',
        message: 'Overlaps with another session',
        showToUser: true,
      );

      expect(error.toJson(), <String, dynamic>{
        'code': 'schedule_conflict',
        'message': 'Overlaps with another session',
        'show_to_user': true,
      });
    });

    test('copyWith overrides showToUser independently', () {
      const error = ApiError(code: 'x', message: 'y');

      expect(error.copyWith(showToUser: true).showToUser, isTrue);
      expect(error.copyWith().showToUser, isFalse);
    });

    test('props include show_to_user', () {
      const a = ApiError(code: 'x', message: 'y');
      const b = ApiError(code: 'x', message: 'y', showToUser: true);

      expect(a == b, isFalse);
    });
  });
}
