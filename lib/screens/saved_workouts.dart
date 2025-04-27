// screens/saved_workouts.dart - 已保存的訓練頁面
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/timer_provider.dart';
import '../models/workout_model.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';

class SavedWorkoutsScreen extends StatelessWidget {
  const SavedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workouts = workoutProvider.workouts;

    return Scaffold(
      appBar: AppBar(
        title: Text('我的訓練計劃'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(isNew: true),
                ),
              );
            },
          ),
        ],
      ),
      body:
          workoutProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : workouts.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '沒有保存的訓練計劃',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      child: Text('創建新訓練'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(isNew: true),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return WorkoutCard(workout: workout);
                },
              ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );

    // 格式化時間
    String formatSeconds(int seconds) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return mins > 0 ? '$mins分$secs秒' : '$secs秒';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          timerProvider.startWorkout(workout);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimerScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      workout.isFavorite ? Icons.star : Icons.star_border,
                      color: workout.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      workoutProvider.toggleFavorite(workout.id);
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.fitness_center,
                      label: '運動',
                      value: formatSeconds(workout.workSeconds),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.pause,
                      label: '休息',
                      value: formatSeconds(workout.restSeconds),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.repeat,
                      label: '循環',
                      value: '${workout.cycles}次',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              if (workout.warmupSeconds > 0 || workout.cooldownSeconds > 0)
                Row(
                  children: [
                    if (workout.warmupSeconds > 0)
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.whatshot,
                          label: '預熱',
                          value: formatSeconds(workout.warmupSeconds),
                        ),
                      ),
                    if (workout.cooldownSeconds > 0)
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.ac_unit,
                          label: '緩和',
                          value: formatSeconds(workout.cooldownSeconds),
                        ),
                      ),
                    // 平衡布局
                    if (workout.warmupSeconds == 0 ||
                        workout.cooldownSeconds == 0)
                      Expanded(child: Container()),
                  ],
                ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('編輯'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SettingsScreen(
                                workout: workout,
                                isNew: false,
                              ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: Text('確認刪除'),
                              content: Text('你確定要刪除「${workout.name}」訓練計劃嗎？'),
                              actions: [
                                TextButton(
                                  child: Text('取消'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    workoutProvider.deleteWorkout(workout.id);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text('刪除'),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Text('刪除'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
