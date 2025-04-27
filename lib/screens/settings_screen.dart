// screens/settings_screen.dart - 設置頁面
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';

class SettingsScreen extends StatefulWidget {
  final WorkoutModel? workout;
  final bool isNew;

  const SettingsScreen({super.key, this.workout, required this.isNew});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  int _workSeconds = 45;
  int _restSeconds = 15;
  int _cycles = 8;
  int _warmupSeconds = 60;
  int _cooldownSeconds = 60;

  @override
  void initState() {
    super.initState();

    // 如果是編輯現有的訓練，則使用其值
    if (widget.workout != null) {
      _nameController = TextEditingController(text: widget.workout!.name);
      _workSeconds = widget.workout!.workSeconds;
      _restSeconds = widget.workout!.restSeconds;
      _cycles = widget.workout!.cycles;
      _warmupSeconds = widget.workout!.warmupSeconds;
      _cooldownSeconds = widget.workout!.cooldownSeconds;
    } else {
      _nameController = TextEditingController(text: '新訓練計劃');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );

      if (widget.isNew) {
        // 創建新訓練
        final newWorkout = WorkoutModel(
          id: '', // ID 將在 provider 中生成
          name: _nameController.text,
          workSeconds: _workSeconds,
          restSeconds: _restSeconds,
          cycles: _cycles,
          warmupSeconds: _warmupSeconds,
          cooldownSeconds: _cooldownSeconds,
        );

        workoutProvider.addWorkout(newWorkout);
      } else {
        // 更新現有訓練
        final updatedWorkout = widget.workout!.copyWith(
          name: _nameController.text,
          workSeconds: _workSeconds,
          restSeconds: _restSeconds,
          cycles: _cycles,
          warmupSeconds: _warmupSeconds,
          cooldownSeconds: _cooldownSeconds,
        );

        workoutProvider.updateWorkout(updatedWorkout);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? '創建新訓練' : '編輯訓練'),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: _saveWorkout)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '訓練名稱',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入訓練名稱';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildTimeSettingCard(
              title: '運動與休息時間',
              children: [
                _buildSliderSetting(
                  icon: Icons.fitness_center,
                  label: '運動時間',
                  value: _workSeconds.toDouble(), // 將 int 轉換為 double
                  min: 5,
                  max: 300,
                  onChanged: (value) {
                    setState(() {
                      _workSeconds = value.toInt(); // 更新為 int
                    });
                  },
                  formatValue: _formatDuration,
                ),
                SizedBox(height: 16),
                _buildSliderSetting(
                  icon: Icons.pause,
                  label: '休息時間',
                  value: _restSeconds.toDouble(), // 將 int 轉換為 double
                  min: 5,
                  max: 180,
                  onChanged: (value) {
                    setState(() {
                      _restSeconds = value.toInt(); // 更新為 int
                    });
                  },
                  formatValue: _formatDuration,
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTimeSettingCard(
              title: '循環次數',
              children: [
                _buildNumberSelector(
                  label: '循環次數',
                  value: _cycles,
                  min: 1,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      _cycles = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTimeSettingCard(
              title: '預熱與緩和時間',
              children: [
                _buildSliderSetting(
                  icon: Icons.whatshot,
                  label: '預熱時間',
                  value: _warmupSeconds.toDouble(),
                  min: 0,
                  max: 300,
                  onChanged: (value) {
                    setState(() {
                      _warmupSeconds = value.toInt();
                    });
                  },
                  formatValue: _formatDuration,
                ),
                SizedBox(height: 16),
                _buildSliderSetting(
                  icon: Icons.ac_unit,
                  label: '緩和時間',
                  value: _cooldownSeconds.toDouble(),
                  min: 0,
                  max: 300,
                  onChanged: (value) {
                    setState(() {
                      _cooldownSeconds = value.toInt();
                    });
                  },
                  formatValue: _formatDuration,
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildWorkoutSummary(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('儲存訓練', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettingCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String Function(int) formatValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Text(
              formatValue(value.toInt()),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 5).round(),
            label: formatValue(value.toInt()),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberSelector({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              _buildNumberButton(
                icon: Icons.remove,
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  value.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildNumberButton(
                icon: Icons.add,
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              onPressed == null
                  ? Colors.grey.shade200
                  : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color:
              onPressed == null
                  ? Colors.grey.shade400
                  : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildWorkoutSummary() {
    // 計算總時間
    final totalWorkTime = _workSeconds * _cycles;
    final totalRestTime = _restSeconds * (_cycles - 1);
    final totalTime =
        _warmupSeconds + totalWorkTime + totalRestTime + _cooldownSeconds;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '訓練摘要',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('總訓練時間: ${_formatDuration(totalTime)}'),
            SizedBox(height: 4),
            Text('運動時間: ${_formatDuration(totalWorkTime)}'),
            SizedBox(height: 4),
            Text('休息時間: ${_formatDuration(totalRestTime)}'),
            if (_warmupSeconds > 0) ...[
              SizedBox(height: 4),
              Text('預熱時間: ${_formatDuration(_warmupSeconds)}'),
            ],
            if (_cooldownSeconds > 0) ...[
              SizedBox(height: 4),
              Text('緩和時間: ${_formatDuration(_cooldownSeconds)}'),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds秒';
    } else {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return mins > 0 && secs > 0 ? '$mins分$secs秒' : '$mins分';
    }
  }
}
