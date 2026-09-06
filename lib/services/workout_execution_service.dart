import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import 'analytics_service.dart';
import 'ble_sensor_service.dart';

enum WorkoutExecutionState { initial, running, paused, completed }

class LapSplit {
  final int lapIndex;
  final String duration;
  final String pace;
  final int avgHeartRate;

  const LapSplit({
    required this.lapIndex,
    required this.duration,
    required this.pace,
    required this.avgHeartRate,
  });
}

class WorkoutExecutionService extends ChangeNotifier {
  final Workout workout;
  Timer? _timer;

  int _elapsedSeconds = 0;
  int _currentHeartRate = 142;
  int _currentCadence = 172;
  double _distanceKm = 0.0;
  WorkoutExecutionState _state = WorkoutExecutionState.initial;
  final List<LapSplit> _laps = [];
  final BleSensorService _bleSensor = BleSensorService();

  WorkoutExecutionService({required this.workout}) {
    _bleSensor.addListener(_onBleSensorUpdate);
    if (_bleSensor.isConnected) {
      _currentHeartRate = _bleSensor.liveHeartRate;
    }
  }

  void _onBleSensorUpdate() {
    if (_bleSensor.isConnected) {
      _currentHeartRate = _bleSensor.liveHeartRate;
      notifyListeners();
    }
  }

  int get elapsedSeconds => _elapsedSeconds;
  int get currentHeartRate => _currentHeartRate;
  int get currentCadence => _currentCadence;
  double get distanceKm => _distanceKm;
  WorkoutExecutionState get state => _state;
  List<LapSplit> get laps => List.unmodifiable(_laps);
  bool get isBleConnected => _bleSensor.isConnected;
  String? get connectedDeviceName => _bleSensor.connectedDeviceName;
  bool get isDemoMode => kDebugMode && !_bleSensor.isConnected;

  String get formattedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final mins = (_elapsedSeconds % 3600) ~/ 60;
    final secs = _elapsedSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get currentPace {
    if (_distanceKm <= 0.01) return '0:00 /km';
    final totalMins = _elapsedSeconds / 60.0;
    final paceDecimal = totalMins / _distanceKm;
    final pMins = paceDecimal.toInt();
    final pSecs = ((paceDecimal - pMins) * 60).toInt();
    return '$pMins:${pSecs.toString().padLeft(2, '0')} /km';
  }

  int get calculatedTss {
    final hours = _elapsedSeconds / 3600.0;
    return (hours * 65.0).toInt();
  }

  int get currentZone {
    if (_currentHeartRate < 120) return 1;
    if (_currentHeartRate < 140) return 2;
    if (_currentHeartRate < 155) return 3;
    if (_currentHeartRate < 170) return 4;
    return 5;
  }

  void start() {
    if (_state == WorkoutExecutionState.running) return;
    _state = WorkoutExecutionState.running;
    AnalyticsService.logWorkoutStarted(workout.id, workout.sport.name);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _elapsedSeconds++;
      _distanceKm += 0.0032; // ~11.5 km/h simulation pace
      if (!_bleSensor.isConnected) {
        _currentHeartRate = 135 + (_elapsedSeconds % 25);
        // Simulate realistic cadence variation between 165-180 spm
        _currentCadence = 172 + (_elapsedSeconds % 9 - 4);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _state = WorkoutExecutionState.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void recordLap() {
    _laps.add(
      LapSplit(
        lapIndex: _laps.length + 1,
        duration: formattedTime,
        pace: currentPace,
        avgHeartRate: _currentHeartRate,
      ),
    );
    notifyListeners();
  }

  Future<void> finish() async {
    _timer?.cancel();
    _state = WorkoutExecutionState.completed;
    try {
      await WorkoutService().complete(workout.id, progress: 1.0);
      await AnalyticsService.logWorkoutCompleted(
        workout.id,
        workout.sport.name,
        _distanceKm,
        calculatedTss,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to complete workout: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bleSensor.removeListener(_onBleSensorUpdate);
    super.dispose();
  }
}
