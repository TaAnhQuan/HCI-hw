import 'dart:async';

enum ClockType { system, user }

// Used to manage the clock created
class TimerManager {
  // Single instance mode manages all timers
  static final TimerManager _instance = TimerManager._internal();
  factory TimerManager() => _instance;
  TimerManager._internal();

  // Storage clock
  final Map<String, _Clock> _clocks = {};

  // Add or update clock
  void startTimer(String name, Duration duration, void Function() onFinish, ClockType type) {
    if (_clocks.containsKey(name)) {
      _clocks[name]!.updateTime(duration);
    } else {
      _clocks[name] = _Clock(name, duration, () {
        // Delete the corresponding clock when the countdown ends
        stopTimer(name);
        onFinish();
      }, type);
      _clocks[name]!.start();
    }
  }

  // Get all clocks
  Map<String, _Clock> getAllClocks() => _clocks;

  // Retrieve the clock created by the user
  Map<String, _Clock> getUserClocks() {
    return Map.fromEntries(
      _clocks.entries.where((entry) => entry.value.type == ClockType.user),
    );
  }

  // stop clock
  void stopTimer(String name) {
    if (_clocks.containsKey(name)) {
      _clocks[name]!.stop();
      _clocks.remove(name);
    }
  }
}

// Private class to represent clock
class _Clock {
  // Clock name Clock timing Time object End time End callback function
  final String name;
  Duration duration;
  Timer? _timer;
  late DateTime _endTime;
  final void Function() onFinish;
  final ClockType type;

  _Clock(this.name, this.duration, this.onFinish, this.type);

  void start() {
    _endTime = DateTime.now().add(duration);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remainingTime = _endTime.difference(now);
      if (remainingTime.isNegative) {
        timer.cancel();
        onFinish();
      } else {
        duration = remainingTime;
        print('$name time: ${remainingTime.inSeconds} s');
      }
    });
  }

  void updateTime(Duration newDuration) {
    duration = newDuration;
    _endTime = DateTime.now().add(duration);
  }

  void stop() {
    _timer?.cancel();
  }
}