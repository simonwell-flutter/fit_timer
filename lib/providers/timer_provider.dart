import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import '../models/workout_model.dart';

enum TimerStatus { initial, running, paused, finished }

enum TimerPhase { warmup, work, rest, cooldown, complete }

class TimerProvider with ChangeNotifier {
  TimerStatus _status = TimerStatus.initial;
  TimerPhase _phase = TimerPhase.warmup;

  WorkoutModel? _currentWorkout;
  int _currentCycle = 0;
  int _secondsRemaining = 0;
  Timer? _timer;

  // Audio players
  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _phaseChangePlayer = AudioPlayer();
  final AudioPlayer _completePlayer = AudioPlayer();
  final AudioPlayer _phaseEndPlayer = AudioPlayer();
  final AudioPlayer _countThreePlayer = AudioPlayer();
  final AudioPlayer _countTwoPlayer = AudioPlayer();
  final AudioPlayer _countOnePlayer = AudioPlayer();

  TimerProvider() {
    _initializeAudio();
    // 設定預設訓練計畫
    _currentWorkout = WorkoutModel(
      id: 'default',
      name: '預設訓練',
      workSeconds: 30, // 運動時間 30 秒
      restSeconds: 10, // 休息時間 10 秒
      warmupSeconds: 5, // 預熱時間 5 秒
      cooldownSeconds: 5, // 緩和時間 5 秒
      cycles: 3, // 循環次數 3 次
    );
    _phase =
        _currentWorkout!.warmupSeconds > 0
            ? TimerPhase.warmup
            : TimerPhase.work;
    _secondsRemaining =
        _currentWorkout!.warmupSeconds > 0
            ? _currentWorkout!.warmupSeconds
            : _currentWorkout!.workSeconds;
  }

  Future<void> _initializeAudio() async {
    try {
      await _tickPlayer.setAsset('assets/sounds/tick.mp3');
      await _tickPlayer.setVolume(1.0);
      await _phaseChangePlayer.setAsset('assets/sounds/phase_change.mp3');
      await _completePlayer.setAsset('assets/sounds/complete.mp3');
      await _phaseEndPlayer.setAsset('assets/sounds/phase_end.mp3');
      await _countThreePlayer.setAsset('assets/sounds/three.mp3');
      await _countTwoPlayer.setAsset('assets/sounds/two.mp3');
      await _countOnePlayer.setAsset('assets/sounds/one.mp3');
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  // Getters
  TimerStatus get status => _status;
  TimerPhase get phase => _phase;
  WorkoutModel? get currentWorkout => _currentWorkout;
  int get currentCycle => _currentCycle;
  int get secondsRemaining => _secondsRemaining;
  int get totalCycles => _currentWorkout?.cycles ?? 0;

  double get progress {
    if (_currentWorkout == null) return 0;

    int totalTime = calculateTotalTime();
    int elapsedTime = calculateElapsedTime();

    return totalTime > 0 ? elapsedTime / totalTime : 0;
  }

  // 開始新的訓練
  void startWorkout(WorkoutModel workout) {
    _currentWorkout = workout;
    _currentCycle = 0;
    _phase = workout.warmupSeconds > 0 ? TimerPhase.warmup : TimerPhase.work;
    _secondsRemaining =
        workout.warmupSeconds > 0 ? workout.warmupSeconds : workout.workSeconds;
    _status = TimerStatus.initial;
    notifyListeners();
  }

  // 設置時間
  void setWorkSeconds(int seconds) {
    if (_currentWorkout != null) {
      _currentWorkout!.workSeconds = seconds;
      notifyListeners();
    }
  }

  void setRestSeconds(int seconds) {
    if (_currentWorkout != null) {
      _currentWorkout!.restSeconds = seconds;
      notifyListeners();
    }
  }

  void setWarmupSeconds(int seconds) {
    if (_currentWorkout != null) {
      _currentWorkout!.warmupSeconds = seconds;
      notifyListeners();
    }
  }

  void setCooldownSeconds(int seconds) {
    if (_currentWorkout != null) {
      _currentWorkout!.cooldownSeconds = seconds;
      notifyListeners();
    }
  }

  // 開始/恢復計時
  void start() {
    if (_status == TimerStatus.running) return;

    _status = TimerStatus.running;
    _timer = Timer.periodic(Duration(seconds: 1), _tick);
    notifyListeners();
  }

  // 暫停計時
  void pause() {
    if (_status != TimerStatus.running) return;

    _status = TimerStatus.paused;
    _timer?.cancel();
    notifyListeners();
  }

  // 重置計時
  void reset() {
    _timer?.cancel();
    if (_currentWorkout != null) {
      _phase =
          _currentWorkout!.warmupSeconds > 0
              ? TimerPhase.warmup
              : TimerPhase.work;
      _secondsRemaining =
          _currentWorkout!.warmupSeconds > 0
              ? _currentWorkout!.warmupSeconds
              : _currentWorkout!.workSeconds;
    }

    _currentCycle = 0;
    _status = TimerStatus.initial;
    notifyListeners();
  }

  // 計時器跳動
  void _tick(Timer timer) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      // 只在運動階段播放滴答聲
      if (_phase == TimerPhase.work) {
        _tickPlayer.seek(Duration.zero);
        _tickPlayer.play();
      }
      if (_secondsRemaining == 3) {
        _countThreePlayer.seek(Duration.zero);
        _countThreePlayer.play();
      } else if (_secondsRemaining == 2) {
        _countTwoPlayer.seek(Duration.zero);
        _countTwoPlayer.play();
      } else if (_secondsRemaining == 1) {
        _countOnePlayer.seek(Duration.zero);
        _countOnePlayer.play();
      }
      if (_secondsRemaining == 0) {
        _phaseEndPlayer.seek(Duration.zero);
        _phaseEndPlayer.play();
      }
    } else {
      _moveToNextPhase();
    }
    notifyListeners();
  }

  // 移動到下一階段
  void _moveToNextPhase() {
    if (_currentWorkout == null) return;

    switch (_phase) {
      case TimerPhase.warmup:
        _phase = TimerPhase.work;
        _secondsRemaining = _currentWorkout!.workSeconds;
        break;
      case TimerPhase.work:
        if (_currentCycle < _currentWorkout!.cycles - 1) {
          _phase = TimerPhase.rest;
          _secondsRemaining = _currentWorkout!.restSeconds;
        } else if (_currentWorkout!.cooldownSeconds > 0) {
          _phase = TimerPhase.cooldown;
          _secondsRemaining = _currentWorkout!.cooldownSeconds;
        } else {
          _complete();
        }
        break;
      case TimerPhase.rest:
        _phase = TimerPhase.work;
        _currentCycle++;
        _secondsRemaining = _currentWorkout!.workSeconds;
        break;
      case TimerPhase.cooldown:
        _complete();
        break;
      case TimerPhase.complete:
        break;
    }
  }

  // 完成訓練
  void _complete() {
    _timer?.cancel();
    _phase = TimerPhase.complete;
    _status = TimerStatus.finished;
    _completePlayer.seek(Duration.zero);
    _completePlayer.play();
  }

  // 計算總時間
  int calculateTotalTime() {
    if (_currentWorkout == null) return 0;

    return _currentWorkout!.warmupSeconds +
        (_currentWorkout!.workSeconds + _currentWorkout!.restSeconds) *
            _currentWorkout!.cycles +
        _currentWorkout!.cooldownSeconds;
  }

  // 計算已經過的時間
  int calculateElapsedTime() {
    if (_currentWorkout == null) return 0;

    int elapsed = 0;

    // 預熱階段
    if (_phase == TimerPhase.warmup) {
      elapsed = _currentWorkout!.warmupSeconds - _secondsRemaining;
    } else {
      elapsed = _currentWorkout!.warmupSeconds;
    }

    // 運動和休息階段
    if (_phase == TimerPhase.work || _phase == TimerPhase.rest) {
      elapsed +=
          (_currentWorkout!.workSeconds + _currentWorkout!.restSeconds) *
          _currentCycle;
      if (_phase == TimerPhase.work) {
        elapsed += _currentWorkout!.workSeconds - _secondsRemaining;
      } else {
        elapsed +=
            _currentWorkout!.workSeconds +
            (_currentWorkout!.restSeconds - _secondsRemaining);
      }
    } else if (_phase == TimerPhase.cooldown || _phase == TimerPhase.complete) {
      elapsed +=
          (_currentWorkout!.workSeconds + _currentWorkout!.restSeconds) *
          _currentWorkout!.cycles;
      if (_phase == TimerPhase.cooldown) {
        elapsed += _currentWorkout!.cooldownSeconds - _secondsRemaining;
      } else {
        elapsed += _currentWorkout!.cooldownSeconds;
      }
    }

    return elapsed;
  }

  // 保存計時器設置
  Future<void> saveTimerSettings() async {
    if (_currentWorkout == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('workSeconds', _currentWorkout!.workSeconds);
    prefs.setInt('restSeconds', _currentWorkout!.restSeconds);
    prefs.setInt('warmupSeconds', _currentWorkout!.warmupSeconds);
    prefs.setInt('cooldownSeconds', _currentWorkout!.cooldownSeconds);
    prefs.setInt('cycles', _currentWorkout!.cycles);

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tickPlayer.dispose();
    _phaseChangePlayer.dispose();
    _completePlayer.dispose();
    _phaseEndPlayer.dispose();
    _countThreePlayer.dispose();
    _countTwoPlayer.dispose();
    _countOnePlayer.dispose();
    super.dispose();
  }
}
