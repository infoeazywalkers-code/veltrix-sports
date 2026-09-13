import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/activity/activity.dart';

class LiveRecordingScreen extends StatefulWidget {
  const LiveRecordingScreen({super.key});

  @override
  State<LiveRecordingScreen> createState() => _LiveRecordingScreenState();
}

class _LiveRecordingScreenState extends State<LiveRecordingScreen> {
  bool _isRecording = false;
  bool _isPaused = false;
  SportType _selectedSport = SportType.cycling;
  Timer? _timer;
  int _elapsedSeconds = 0;

  double _distanceKm = 0;
  int _elevationGainM = 0;
  double _avgSpeedKmh = 0;
  double _currentSpeedKmh = 0;
  int? _avgHeartRate;
  int? _currentHeartRate;
  int? _avgPower;
  int? _currentPower;
  int? _currentCadence;

  // GPS points for simulated route
  final List<_LapMarker> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      _isPaused = false;
    });

    if (_isRecording) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsedSeconds++;
          _updateSimulatedData();
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsedSeconds++;
          _updateSimulatedData();
        });
      });
    }
  }

  void _addLap() {
    setState(() {
      _laps.add(
        _LapMarker(
          number: _laps.length + 1,
          distance: _distanceKm,
          time: _formatDuration(_elapsedSeconds),
          speed: _currentSpeedKmh,
        ),
      );
    });
  }

  void _updateSimulatedData() {
    // Simulate realistic training data
    final random = (DateTime.now().millisecondsSinceEpoch % 100) / 100;
    _distanceKm += 0.008 + random * 0.004;
    _currentSpeedKmh = 25 + random * 15;
    _avgSpeedKmh =
        _distanceKm > 0 ? (_distanceKm / (_elapsedSeconds / 3600)) : 0;
    _elevationGainM = (_distanceKm * 12).round();

    if (_selectedSport == SportType.cycling) {
      _currentPower = 200 + (random * 100).round();
      _currentCadence = 85 + (random * 15).round();
      _currentHeartRate = 145 + (random * 30).round();
    } else {
      _currentHeartRate = 155 + (random * 25).round();
      _currentCadence = 170 + (random * 20).round();
    }

    _avgHeartRate =
        _avgHeartRate == null
            ? _currentHeartRate
            : ((_avgHeartRate! + _currentHeartRate!) ~/ 2);
    _avgPower =
        _avgPower == null
            ? _currentPower
            : ((_avgPower! + _currentPower!) ~/ 2);
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _sportEmoji(SportType sport) {
    switch (sport) {
      case SportType.cycling:
        return '🚴';
      case SportType.running:
        return '🏃';
      case SportType.trailRunning:
        return '⛰️';
      case SportType.gravel:
        return '🛤️';
      case SportType.rowing:
        return '🚣';
      case SportType.swimming:
        return '🏊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'LIVE RECORDING',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.layers, color: Colors.white54),
                    onPressed: _addLap,
                  ),
                ],
              ),
            ),

            // Sport selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    SportType.values.take(4).map((sport) {
                      final isSelected = sport == _selectedSport;
                      return GestureDetector(
                        onTap: () {
                          if (!_isRecording) {
                            setState(() => _selectedSport = sport);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(
                                      0xFFF97316,
                                    ).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFFF97316)
                                      : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            _sportEmoji(sport),
                            style: TextStyle(
                              fontSize: isSelected ? 22 : 18,
                              color: isSelected ? null : Colors.white38,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Main timer
            Text(
              _formatDuration(_elapsedSeconds),
              style: TextStyle(
                color:
                    _isRecording
                        ? (_isPaused ? const Color(0xFFFBBF24) : Colors.white)
                        : Colors.white24,
                fontSize: 56,
                fontWeight: FontWeight.w200,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),

            const SizedBox(height: 4),

            // Status indicator
            if (_isRecording)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _isPaused
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPaused ? 'PAUSED' : 'RECORDING',
                    style: TextStyle(
                      color:
                          _isPaused
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Primary stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  _primaryStat(
                    'Distance',
                    '${_distanceKm.toStringAsFixed(2)} km',
                  ),
                  _primaryStat(
                    'Speed',
                    '${_currentSpeedKmh.toStringAsFixed(1)} km/h',
                  ),
                  _primaryStat('Elevation', '+${_elevationGainM}m'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Secondary stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (_currentHeartRate != null)
                    _secondaryStat(
                      '❤️',
                      'HR',
                      '${_currentHeartRate} bpm',
                      const Color(0xFFEF4444),
                    ),
                  if (_currentPower != null) ...[
                    const SizedBox(width: 8),
                    _secondaryStat(
                      '⚡',
                      'Power',
                      '${_currentPower}W',
                      const Color(0xFFF97316),
                    ),
                  ],
                  const SizedBox(width: 8),
                  _secondaryStat(
                    '🔄',
                    'Cadence',
                    '${_currentCadence ?? 0}',
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  _secondaryStat(
                    '📊',
                    'Avg Speed',
                    '${_avgSpeedKmh.toStringAsFixed(1)}',
                    const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Laps list
            if (_laps.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _laps.length,
                  itemBuilder: (context, index) {
                    final lap = _laps[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LAP ${lap.number}',
                            style: const TextStyle(
                              color: Color(0xFFF97316),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            lap.time,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${lap.speed.toStringAsFixed(1)} km/h',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Control buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop button
                  GestureDetector(
                    onTap:
                        _isRecording
                            ? () {
                              _timer?.cancel();
                              setState(() {
                                _isRecording = false;
                                _isPaused = false;
                              });
                              // Save activity logic would go here
                            }
                            : null,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            _isRecording
                                ? const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _isRecording
                                  ? const Color(0xFFEF4444)
                                  : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.stop,
                        color:
                            _isRecording
                                ? const Color(0xFFEF4444)
                                : Colors.white24,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Play/Pause button
                  GestureDetector(
                    onTap: _isRecording ? _togglePause : _toggleRecording,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color:
                            _isRecording
                                ? (_isPaused
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFFBBF24))
                                : const Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRecording
                            ? (_isPaused ? Icons.play_arrow : Icons.pause)
                            : Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Lap button
                  GestureDetector(
                    onTap: _isRecording ? _addLap : null,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            _isRecording
                                ? const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _isRecording
                                  ? const Color(0xFF3B82F6)
                                  : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.flag,
                        color:
                            _isRecording
                                ? const Color(0xFF3B82F6)
                                : Colors.white24,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondaryStat(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LapMarker {
  final int number;
  final double distance;
  final String time;
  final double speed;

  const _LapMarker({
    required this.number,
    required this.distance,
    required this.time,
    required this.speed,
  });
}
