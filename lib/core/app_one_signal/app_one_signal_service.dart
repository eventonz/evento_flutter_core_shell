abstract class AppOneSignal {
  Future<String> setOneSignalUserId();
  Future<void> updateNotificationStatus(
      String userId, int eventId, bool notificationStatus);
}
