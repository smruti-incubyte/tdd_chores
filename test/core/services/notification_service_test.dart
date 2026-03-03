import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/services/notification_service.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  // -when notification permission allowed & token not null & user not null, saved in db
  // -when notification permission allowed & token null, not saved in db
  // -when notification permission not allowed token not saved to db (no)

  //  -when notification permission allowed & token not null & user null, not saved in db
  // boundaries - permission, token , authentication
  late MockNotificationRepository mockNotificationRepository;
  late NotificationService notificationService;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    notificationService = NotificationService(
      notificationRepository: mockNotificationRepository,
    );
  });

  test(
    "when notification permission allowed & token not null & user not null, saved in db",
    () async {
      // Arrange
      when(
        mockNotificationRepository.getNotificationPermission(),
      ).thenAnswer((_) async => true);
      when(
        mockNotificationRepository.getFcmToken(),
      ).thenAnswer((_) async => 'valid-token');
      when(
        mockNotificationRepository.getUser(),
      ).thenAnswer((_) async => 'valid-id');

      //Act
      await notificationService.saveToken();

      //Assert
      verify(mockNotificationRepository.getNotificationPermission()).called(1);
      verify(mockNotificationRepository.getFcmToken()).called(1);
      verify(mockNotificationRepository.getUser()).called(1);
      verify(
        mockNotificationRepository.saveFcmToken(
          token: 'valid-token',
          user: 'valid-id',
        ),
      ).called(1);
    },
  );

  test(
    "when notification permission allowed & token null, not saved in db",
    () async {
      // Arrange
      when(
        mockNotificationRepository.getNotificationPermission(),
      ).thenAnswer((_) async => true);
      when(
        mockNotificationRepository.getFcmToken(),
      ).thenAnswer((_) async => null);
      when(
        mockNotificationRepository.getUser(),
      ).thenAnswer((_) async => 'valid-id');
      //Act
      await notificationService.saveToken();

      //Assert
      verify(mockNotificationRepository.getNotificationPermission()).called(1);
      verify(mockNotificationRepository.getFcmToken()).called(1);
      verifyNever(
        mockNotificationRepository.saveFcmToken(
          token: 'valid-token',
          user: 'valid-id',
        ),
      );
    },
  );

  test(
    "when notification permission not allowed token not saved to db.",
    () async {
      // Arrange
      when(
        mockNotificationRepository.getNotificationPermission(),
      ).thenAnswer((_) async => false);

      //Act
      await notificationService.saveToken();

      //Assert
      verify(mockNotificationRepository.getNotificationPermission()).called(1);
      verifyNever(mockNotificationRepository.getFcmToken());
      verifyNever(mockNotificationRepository.getUser());
      verifyNever(
        mockNotificationRepository.saveFcmToken(
          token: 'valid-token',
          user: 'valid-id',
        ),
      );
    },
  );

  test(
    "when notification permission allowed & token not null & user null, not saved in db",
    () async {
      // Arrange
      when(
        mockNotificationRepository.getNotificationPermission(),
      ).thenAnswer((_) async => true);
      when(
        mockNotificationRepository.getFcmToken(),
      ).thenAnswer((_) async => 'valid-token');
      when(mockNotificationRepository.getUser()).thenAnswer((_) async => null);
      //Act
      await notificationService.saveToken();

      //Assert
      verify(mockNotificationRepository.getNotificationPermission()).called(1);
      verify(mockNotificationRepository.getFcmToken()).called(1);
      verify(mockNotificationRepository.getUser()).called(1);
      verifyNever(
        mockNotificationRepository.saveFcmToken(
          token: 'valid-token',
          user: 'valid-id',
        ),
      );
    },
  );
}
