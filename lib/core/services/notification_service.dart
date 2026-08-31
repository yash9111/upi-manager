import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('upi_tracker/incoming_sms');

  Future<bool> requestPermission() async {
    final result = await _channel.invokeMethod<bool>(
      'requestNotificationPermission',
    );

    return result ?? false;
  }

  Future<bool> areNotificationsEnabled() async {
    final result = await _channel.invokeMethod<bool>(
      'areNotificationsEnabled',
    );

    return result ?? false;
  }

  Future<bool> showTransactionNotification({
    required int notificationId,
    required String title,
    required String body,
    required String transactionId,
  }) async {
    final result = await _channel.invokeMethod<bool>(
      'showTransactionNotification',
      {
        'notificationId': notificationId,
        'title': title,
        'body': body,
        'transactionId': transactionId,
      },
    );

    return result ?? false;
  }

  Future<String?> getInitialTransactionId() async {
    return _channel.invokeMethod<String>(
      'getInitialTransactionId',
    );
  }

  void setNotificationTapHandler(
    void Function(String transactionId) handler,
  ) {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'notificationTapped') {
        return;
      }

      final transactionId =
          call.arguments as String?;

      if (transactionId == null ||
          transactionId.isEmpty) {
        return;
      }

      handler(transactionId);
    });
  }
}