import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

class DeviceService {
  static const String _prefix = 'device_status_';
  static const String _lastSyncPrefix = 'device_sync_';

  static Future<bool> isConnected(String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$deviceName') ?? false;
  }

  static Future<void> setConnected(String deviceName, String category, bool connected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$deviceName', connected);
    if (connected) {
      await prefs.setString('$_lastSyncPrefix$deviceName', DateTime.now().toIso8601String());
      await AnalyticsService.logDevicePaired(deviceName, category);
    }
  }

  static Future<String> getLastSync(String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_lastSyncPrefix$deviceName');
    if (raw == null) return 'Never';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> forceSync(String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_lastSyncPrefix$deviceName', DateTime.now().toIso8601String());
  }
}
