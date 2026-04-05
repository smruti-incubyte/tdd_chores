import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/data/models/single_chore.dart';

void main() {
  final tDateTime = DateTime(2024, 1, 1);
  const tPhotoUrl = 'https://example.com/photo.jpg';

  group('SingleChoreModel.fromJson', () {
    test(
      'should set photoUrl to null when the json does not contain photoUrl',
      () {
        final result = SingleChoreModel.fromJson({
          'name': 'Test Chore',
          'dateTime': tDateTime.toIso8601String(),
          'status': ChoreStatus.todo.name,
          'createdBy': '1',
        }, docId: '1');

        expect(result.photoUrl, isNull);
      },
    );
  });

  group('SingleChoreModel.toJson', () {
    test('should include photoUrl in json when photoUrl is present', () {
      final model = SingleChoreModel(
        id: '1',
        name: 'Test Chore',
        dateTime: tDateTime,
        status: ChoreStatus.todo,
        createdBy: '1',
        photoUrl: tPhotoUrl,
      );

      final result = model.toJson();

      expect(result['photoUrl'], equals(tPhotoUrl));
    });
  });
}
