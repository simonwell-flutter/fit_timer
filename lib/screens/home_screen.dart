import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/timer_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';
import '../widgets/progress_indicator.dart'; // 確保正確導入
import 'settings_screen.dart';
import 'saved_workouts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final player = AudioPlayer();

    return Scaffold(
      backgroundColor: Color(0xFF121212), // 深色背景
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E), // 深色AppBar
        title: Text('FitTimer', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.list, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedWorkoutsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SettingsScreen(workout: null, isNew: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 添加動畫效果
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: TimerDisplay(),
            ),
            SizedBox(height: 20),
            // 進度條動畫
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: timerProvider.progress),
              duration: Duration(milliseconds: 300),
              builder: (context, value, child) {
                return CustomProgressIndicator(
                  progress: value,
                  phase: timerProvider.phase.toString(),
                  phaseColor: _getPhaseColor(timerProvider.phase),
                );
              },
            ),
            SizedBox(height: 40),
            // 控制按鈕動畫
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 700),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: ControlButtons(),
            ),
            SizedBox(height: 40),
            if (timerProvider.status == TimerStatus.initial &&
                timerProvider.currentWorkout == null)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBB86FC), // 紫色按鈕
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    await player.setAsset('assets/sounds/workout_start.mp3');
                    await player.play();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavedWorkoutsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    '快速開始訓練',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 根據階段返回不同顏色
  Color _getPhaseColor(TimerPhase phase) {
    switch (phase) {
      case TimerPhase.work:
        return Color(0xFFCF6679); // 柔和的紅色
      case TimerPhase.rest:
        return Color(0xFF03DAC6); // 柔和的藍綠色
      case TimerPhase.warmup:
        return Color(0xFFFFB74D); // 柔和的橙色
      case TimerPhase.cooldown:
        return Color(0xFF81C784); // 柔和的綠色
      default:
        return Color(0xFF9E9E9E); // 柔和的灰色
    }
  }
}
