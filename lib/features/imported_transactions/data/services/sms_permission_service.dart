import 'package:permission_handler/permission_handler.dart';

class SmsPermissionService {
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();

    return status.isGranted;
  }

  Future<bool> isSmsPermissionGranted() async {
    return Permission.sms.isGranted;
  }

  Future<bool> openSettings() async {
    return openAppSettings();
  }
}