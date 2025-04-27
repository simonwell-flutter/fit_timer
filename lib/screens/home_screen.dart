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
      appBar: AppBar(
        title: Text('FitTimer'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedWorkoutsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SettingsScreen(
                        workout: null, // 可以傳遞 null 或者某個訓練模式對象
                        isNew: true, // 設置是否是新訓練模式
                      ),
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
            TimerDisplay(),
            SizedBox(height: 20),
            // 這裡傳遞進度、階段和顏色
            CustomProgressIndicator(
              progress: timerProvider.progress, // 進度
              phase: timerProvider.phase.toString(), // 訓練階段
              phaseColor: _getPhaseColor(timerProvider.phase), // 訓練階段顏色
            ),
            SizedBox(height: 40),
            ControlButtons(),
            SizedBox(height: 40),
            // 如果沒有正在進行的訓練，顯示快速開始按鈕
            if (timerProvider.status == TimerStatus.initial &&
                timerProvider.currentWorkout == null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                child: Text('快速開始訓練'),
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
        return Colors.red; // 運動階段為紅色
      case TimerPhase.rest:
        return Colors.blue; // 休息階段為藍色
      case TimerPhase.warmup:
        return Colors.orange; // 預熱為橙色
      case TimerPhase.cooldown:
        return Colors.green; // 緩和為綠色
      default:
        return Colors.grey; // 默認為灰色
    }
  }
}
