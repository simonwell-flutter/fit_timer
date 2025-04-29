import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';
import '../widgets/progress_indicator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    if (state == AppLifecycleState.paused) {
      _isActive = false;
      if (timerProvider.status == TimerStatus.running) {
        timerProvider.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      _isActive = true;
      if (timerProvider.status == TimerStatus.paused) {
        _showResumeDialog();
      }
    }
  }

  void _showResumeDialog() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Color(0xFF1E1E1E),
            title: Text('繼續訓練？', style: TextStyle(color: Colors.white)),
            content: Text(
              '你想要繼續當前的訓練嗎？',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: Text('繼續'),
                onPressed: () {
                  timerProvider.start();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  void _showExitDialog() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Color(0xFF1E1E1E),
            title: Text('退出訓練', style: TextStyle(color: Colors.white)),
            content: Text(
              '你確定要退出訓練嗎？',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Color(0xFFCF6679)),
                onPressed: () {
                  timerProvider.reset();
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: Text('退出'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final workout = timerProvider.currentWorkout;

    if (workout == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }

    if (timerProvider.phase == TimerPhase.complete && _isActive) {
      return _buildCompletionScreen();
    }

    return WillPopScope(
      onWillPop: () async {
        if (timerProvider.status == TimerStatus.running) {
          _showExitDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(workout.name, style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (timerProvider.status == TimerStatus.running) {
                _showExitDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimerDisplay(),
                SizedBox(height: 40),
                CustomProgressIndicator(
                  progress: timerProvider.progress,
                  phase: timerProvider.phase.toString(),
                  phaseColor: _getPhaseColor(timerProvider.phase),
                ),
                SizedBox(height: 40),
                ControlButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(TimerPhase phase) {
    switch (phase) {
      case TimerPhase.work:
        return Color(0xFFCF6679);
      case TimerPhase.rest:
        return Color(0xFF03DAC6);
      case TimerPhase.warmup:
        return Color(0xFFFFB74D);
      case TimerPhase.cooldown:
        return Color(0xFF81C784);
      default:
        return Color(0xFF9E9E9E);
    }
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('訓練完成', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Color(0xFFBB86FC),
            ),
            SizedBox(height: 24),
            Text(
              '恭喜完成訓練！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '你已經完成了所有的訓練循環',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('返回主頁', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
