import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

enum PermissionType { location, bluetooth, notifications, storage }

enum PermissionStatus {
  granted,
  denied,
  deniedPermanently,
  restricted,
  unknown,
}

class PermissionService {
  PermissionService._();
  static final instance = PermissionService._();

  Future<PermissionStatus> check(PermissionType type) async {
    if (kIsWeb) return PermissionStatus.granted;

    final permission = _mapPermission(type);
    if (permission == null) return PermissionStatus.unknown;

    final status = await permission.status;
    return _mapStatus(status);
  }

  Future<PermissionStatus> request(PermissionType type) async {
    if (kIsWeb) return PermissionStatus.granted;

    final permission = _mapPermission(type);
    if (permission == null) return PermissionStatus.unknown;

    final status = await permission.request();
    return _mapStatus(status);
  }

  Future<Map<PermissionType, PermissionStatus>> requestMultiple(
    List<PermissionType> types,
  ) async {
    if (kIsWeb) {
      return {for (final t in types) t: PermissionStatus.granted};
    }

    final permissions =
        types.map(_mapPermission).whereType<Permission>().toList();
    final statuses = await permissions.request();

    final result = <PermissionType, PermissionStatus>{};
    for (int i = 0; i < types.length; i++) {
      final handlerStatus = statuses[permissions[i]];
      result[types[i]] =
          handlerStatus != null
              ? _mapStatus(handlerStatus)
              : PermissionStatus.denied;
    }
    return result;
  }

  Future<bool> isPermanentlyDenied(PermissionType type) async {
    if (kIsWeb) return false;

    final permission = _mapPermission(type);
    if (permission == null) return false;

    return await permission.isPermanentlyDenied;
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  String getRationale(PermissionType type) {
    switch (type) {
      case PermissionType.location:
        return 'Location permission is needed to track your workout routes and provide accurate GPS data.';
      case PermissionType.bluetooth:
        return 'Bluetooth permission is needed to connect to your heart rate monitor and other devices.';
      case PermissionType.notifications:
        return 'Notification permission is needed to send you workout reminders and progress updates.';
      case PermissionType.storage:
        return 'Storage permission is needed to save workout data and export your training logs.';
    }
  }

  Permission? _mapPermission(PermissionType type) {
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    switch (type) {
      case PermissionType.location:
        return Permission.locationWhenInUse;
      case PermissionType.bluetooth:
        return Platform.isAndroid
            ? Permission.bluetoothScan
            : Permission.bluetooth;
      case PermissionType.notifications:
        return Permission.notification;
      case PermissionType.storage:
        return Platform.isAndroid ? Permission.storage : null;
    }
  }

  PermissionStatus _mapStatus(dynamic status) {
    final statusString = status.toString();
    if (statusString.contains('granted')) return PermissionStatus.granted;
    if (statusString.contains('permanentlyDenied'))
      return PermissionStatus.deniedPermanently;
    if (statusString.contains('denied')) return PermissionStatus.denied;
    if (statusString.contains('restricted')) return PermissionStatus.restricted;
    return PermissionStatus.unknown;
  }
}
