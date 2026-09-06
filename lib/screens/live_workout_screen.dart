import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/workout.dart';
import '../services/workout_execution_service.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  const LiveWorkoutScreen({super.key, required this.workout});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  late final WorkoutExecutionService _engine;

  @override
  void initState() {
    super.initState();
    _engine = WorkoutExecutionService(workout: widget.workout);
    _engine.addListener(_onEngineUpdate);
  }

  void _onEngineUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.workout.title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Demo Mode Banner
              if (_engine.isDemoMode)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange, width: 0.8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: Colors.orange,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'DEMO MODE — Simulated sensor data',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // Zone Indicator Pill
              Semantics(
                label:
                    'Heart rate zone ${_engine.currentZone}: ${_getZoneLabel(_engine.currentZone)}',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getZoneColor(
                      _engine.currentZone,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getZoneColor(_engine.currentZone),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getZoneColor(_engine.currentZone),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ZONE ${_engine.currentZone} — ${_getZoneLabel(_engine.currentZone)}',
                        style: TextStyle(
                          color: _getZoneColor(_engine.currentZone),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_engine.isBleConnected) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bluetooth_connected,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live Watch Stream: ${_engine.connectedDeviceName ?? 'Connected'}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              // Big Timer Display
              Semantics(
                label: 'Workout timer: ${_engine.formattedTime}',
                liveRegion: true,
                child: Text(
                  _engine.formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Key Metrics Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label:
                            'Distance: ${_engine.distanceKm.toStringAsFixed(2)} kilometers',
                        child: _MetricTile(
                          label: 'DISTANCE',
                          value: '${_engine.distanceKm.toStringAsFixed(2)} km',
                          color: lime,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: 'Pace: ${_engine.currentPace}',
                        child: _MetricTile(
                          label: 'PACE',
                          value: _engine.currentPace,
                          color: blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label:
                            'Heart rate: ${_engine.currentHeartRate} beats per minute',
                        child: _MetricTile(
                          label: 'HEART RATE',
                          value: '${_engine.currentHeartRate} bpm',
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label:
                            'Training stress score: ${_engine.calculatedTss}',
                        child: _MetricTile(
                          label: 'TSS SCORE',
                          value: '${_engine.calculatedTss}',
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lap Splits Table if any
              if (_engine.laps.isNotEmpty)
                Container(
                  height: 110,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: _engine.laps.length,
                    itemBuilder: (ctx, i) {
                      final lap = _engine.laps[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lap ${lap.lapIndex}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              lap.duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              lap.pace,
                              style: const TextStyle(
                                color: lime,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Controls Bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_engine.state == WorkoutExecutionState.running)
                      Semantics(
                        label: 'Record lap',
                        button: true,
                        child: IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                          ),
                          iconSize: 28,
                          onPressed: () => _engine.recordLap(),
                          icon: const Icon(Icons.flag_outlined),
                        ),
                      ),

                    // Main Action Button
                    Semantics(
                      label:
                          _engine.state == WorkoutExecutionState.running
                              ? 'Pause workout'
                              : 'Start workout',
                      button: true,
                      child: GestureDetector(
                        onTap: () {
                          if (_engine.state == WorkoutExecutionState.running) {
                            _engine.pause();
                          } else {
                            _engine.start();
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color:
                                _engine.state == WorkoutExecutionState.running
                                    ? Colors.orange
                                    : lime,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _engine.state == WorkoutExecutionState.running
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: navy,
                            size: 38,
                          ),
                        ),
                      ),
                    ),

                    if (_engine.state != WorkoutExecutionState.initial)
                      Semantics(
                        label: 'Finish and save workout',
                        button: true,
                        child: IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          iconSize: 28,
                          onPressed: () async {
                            await _engine.finish();
                            if (context.mounted) {
                              Navigator.pop(context, true);
                              showFeatureMessage(
                                context,
                                'Workout completed & saved!',
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getZoneColor(int zone) {
    switch (zone) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getZoneLabel(int zone) {
    switch (zone) {
      case 1:
        return 'RECOVERY';
      case 2:
        return 'AEROBIC';
      case 3:
        return 'TEMPO';
      case 4:
        return 'THRESHOLD';
      default:
        return 'ANAEROBIC';
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
