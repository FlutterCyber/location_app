import 'package:permission_handler/permission_handler.dart';

class AllPermissions {
  static Future<void> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.storage,
      Permission.location,
    ].request();
    print(statuses[Permission.location]);
  }
}
