import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double progress; // 進度
  final String phase; // 訓練階段
  final Color phaseColor; // 訓練階段顏色

  const CustomProgressIndicator({
    super.key,
    required this.progress,
    required this.phase,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 顯示進度條和訓練階段
        Text(
          phase,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: phaseColor,
          ),
        ),
        SizedBox(height: 10),
        // 循環進度條
        CircularProgressIndicator(
          value: progress, // 進度值
          strokeWidth: 8.0, // 進度條寬度
          valueColor: AlwaysStoppedAnimation<Color>(phaseColor), // 設置進度條顏色
        ),
      ],
    );
  }
}
