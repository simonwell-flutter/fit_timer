// widgets/timer_display.dart - 計時器顯示元件
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'ripple_animation.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final secondsRemaining = timerProvider.secondsRemaining;

    // 格式化時間
    String minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    String seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

    // 根據階段顯示不同顏色
    Color backgroundColor;
    String phaseText;

    switch (timerProvider.phase) {
      case TimerPhase.warmup:
        backgroundColor = Colors.orange;
        phaseText = '預熱';
        break;
      case TimerPhase.work:
        backgroundColor = Colors.red;
        phaseText = '運動';
        break;
      case TimerPhase.rest:
        backgroundColor = Colors.blue;
        phaseText = '休息';
        break;
      case TimerPhase.cooldown:
        backgroundColor = Colors.green;
        phaseText = '緩和';
        break;
      case TimerPhase.complete:
        backgroundColor = Colors.purple;
        phaseText = '完成';
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (timerProvider.status == TimerStatus.running)
          RippleAnimation(
            size: 350,
            color: backgroundColor,
            rippleCount: 5,
            isActive: true,
          ),
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  phaseText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$minutes:$seconds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (timerProvider.phase != TimerPhase.complete)
                  Text(
                    '循環 ${timerProvider.currentCycle + 1}/${timerProvider.totalCycles}',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
