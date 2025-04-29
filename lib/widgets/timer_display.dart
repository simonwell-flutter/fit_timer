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

    // 根據階段顯示更明顯的三色漸層顏色
    List<Color> gradientColors;
    String phaseText;

    switch (timerProvider.phase) {
      case TimerPhase.warmup:
        gradientColors = [
          Color(0xFFFFF176),
          Color(0xFFFF9800),
          Color(0xFFFF5252),
        ]; // 黃→橙→紅
        phaseText = '預熱';
        break;
      case TimerPhase.work:
        gradientColors = [
          Color(0xFFFF8A65),
          Color(0xFFFF5252),
          Color(0xFFD32F2F),
        ]; // 亮紅→紅→深紅
        phaseText = '運動';
        break;
      case TimerPhase.rest:
        gradientColors = [
          Color(0xFF80D8FF),
          Color(0xFF40C4FF),
          Color(0xFF00BFAE),
        ]; // 亮藍→藍→青綠
        phaseText = '休息';
        break;
      case TimerPhase.cooldown:
        gradientColors = [
          Color(0xFFB9F6CA),
          Color(0xFF81C784),
          Color(0xFF388E3C),
        ]; // 亮綠→綠→深綠
        phaseText = '緩和';
        break;
      case TimerPhase.complete:
        gradientColors = [
          Color(0xFFE1BEE7),
          Color(0xFFAB47BC),
          Color(0xFF7C43BD),
        ]; // 亮紫→紫→深紫
        phaseText = '完成';
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (timerProvider.status == TimerStatus.running)
          RippleAnimation(
            size: 350,
            color: gradientColors[1],
            rippleCount: 5,
            isActive: true,
          ),
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: gradientColors,
              center: Alignment.center,
              radius: 0.95,
            ),
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
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 4,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$minutes:$seconds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 4,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                if (timerProvider.phase != TimerPhase.complete)
                  Text(
                    '循環 ${timerProvider.currentCycle + 1}/${timerProvider.totalCycles}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
