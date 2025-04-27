import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class TimerSettingsScreen extends StatelessWidget {
  const TimerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Timer Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 設置運動時間
            _buildSliderSetting(
              label: '運動時間',
              value:
                  timerProvider.currentWorkout?.workSeconds.toDouble() ?? 30.0,
              min: 5.0,
              max: 300.0,
              onChanged: (value) {
                timerProvider.setWorkSeconds(value.toInt());
              },
            ),
            SizedBox(height: 20),
            // 設置休息時間
            _buildSliderSetting(
              label: '休息時間',
              value:
                  timerProvider.currentWorkout?.restSeconds.toDouble() ?? 10.0,
              min: 5.0,
              max: 180.0,
              onChanged: (value) {
                timerProvider.setRestSeconds(value.toInt());
              },
            ),
            SizedBox(height: 20),
            // 設置預熱時間
            _buildSliderSetting(
              label: '預熱時間',
              value:
                  timerProvider.currentWorkout?.warmupSeconds.toDouble() ?? 5.0,
              min: 0.0,
              max: 20.0,
              onChanged: (value) {
                timerProvider.setWarmupSeconds(value.toInt());
              },
            ),
            SizedBox(height: 20),
            // 設置緩和時間
            _buildSliderSetting(
              label: '緩和時間',
              value:
                  timerProvider.currentWorkout?.cooldownSeconds.toDouble() ??
                  5.0,
              min: 0.0,
              max: 20.0,
              onChanged: (value) {
                timerProvider.setCooldownSeconds(value.toInt());
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 保存設置
                timerProvider.saveTimerSettings();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Settings saved')));
              },
              child: Text('保存設定'),
            ),
          ],
        ),
      ),
    );
  }

  // 創建滑動條設置
  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        Text('${value.toInt()} 秒'),
      ],
    );
  }
}
