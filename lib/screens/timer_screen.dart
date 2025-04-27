import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';
import '../widgets/progress_indicator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key}); // 添加 key 參數

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 保持螢幕常亮
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // 釋放螢幕常亮
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    if (state == AppLifecycleState.paused) {
      _isActive = false;
      // 如果計時器正在運行，則記錄暫停時間
      if (timerProvider.status == TimerStatus.running) {
        timerProvider.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      _isActive = true;
      // 用戶返回應用，提示是否繼續
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
            title: Text('繼續訓練？'),
            content: Text('你想要繼續當前的訓練嗎？'),
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
            title: Text('退出訓練'),
            content: Text('你確定要退出訓練嗎？'),
            actions: [
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: Text('退出'),
                onPressed: () {
                  timerProvider.reset(); // 重置計時器
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // 返回主頁面
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final workout = timerProvider.currentWorkout;

    // 如果沒有正在進行的訓練，返回主頁面
    if (workout == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }

    // 如果訓練完成，顯示完成畫面
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
          title: Text(workout.name),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
                // 計時顯示區域
                TimerDisplay(),
                SizedBox(height: 40),
                // 進度指示器
                CustomProgressIndicator(
                  progress: timerProvider.progress, // 傳遞進度值
                  phase: timerProvider.phase.toString(), // 傳遞當前階段
                  phaseColor: _getPhaseColor(timerProvider.phase), // 根據階段顯示顏色
                ),
                SizedBox(height: 40),
                // 控制按鈕區域
                ControlButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 根據當前階段返回不同的顏色
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

  // 訓練完成畫面
  Widget _buildCompletionScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('訓練完成')),
      body: Center(
        child: Text(
          '恭喜完成訓練！',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
