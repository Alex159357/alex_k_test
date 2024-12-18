import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  Future<bool> getLocationPermissionsStatus() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool?> requestLocationPermissions() async {
    if (await getLocationPermissionsStatus()) {
      return true;
    }

    final status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      return null;
    } else {
      return false;
    }
  }
}
