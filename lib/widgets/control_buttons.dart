// widgets/control_buttons.dart - 控制按鈕元件
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key}); // 使用 super() 直接傳遞 key

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 重置按鈕
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: FloatingActionButton(
            heroTag: 'reset',
            backgroundColor: Colors.grey,
            onPressed:
                timerProvider.currentWorkout != null
                    ? timerProvider.reset
                    : null,
            child: Icon(Icons.refresh),
          ),
        ),
        // 開始/暫停按鈕
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: FloatingActionButton(
            heroTag: 'startPause',
            backgroundColor:
                timerProvider.status == TimerStatus.running
                    ? Colors.orange
                    : Colors.green,
            onPressed:
                timerProvider.currentWorkout != null
                    ? (timerProvider.status == TimerStatus.running
                        ? timerProvider.pause
                        : timerProvider.start)
                    : null,
            child: Icon(
              timerProvider.status == TimerStatus.running
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 30,
            ),
          ),
        ),
        // 停止按鈕
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: FloatingActionButton(
            heroTag: 'stop',
            backgroundColor: Colors.red,
            onPressed:
                timerProvider.currentWorkout != null
                    ? () {
                      timerProvider.reset();
                      // 重定向到主頁面或設置頁面
                    }
                    : null,
            child: Icon(Icons.stop),
          ),
        ),
      ],
    );
  }
}
