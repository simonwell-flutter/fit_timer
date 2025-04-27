// providers/workout_provider.dart - 訓練模式管理
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';
import 'package:uuid/uuid.dart';

class WorkoutProvider with ChangeNotifier {
  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;

  // 構造函數 - 初始化時讀取保存的訓練
  WorkoutProvider() {
    loadWorkouts();
  }

  // 讀取保存的訓練
  Future<void> loadWorkouts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getStringList('workouts') ?? [];

      _workouts = workoutsJson
          .map((json) => WorkoutModel.fromJson(jsonDecode(json)))
          .toList();

      // 如果沒有保存的訓練，添加一些預設訓練模式
      if (_workouts.isEmpty) {
        _addDefaultWorkouts();
      }
    } catch (e) {
      print('載入訓練時出錯: $e');
      // 如果出錯，添加一些預設訓練模式
      _addDefaultWorkouts();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 添加預設訓練模式
  void _addDefaultWorkouts() {
    _workouts = [
      WorkoutModel(
        id: Uuid().v4(),
        name: '塔巴塔訓練',
        workSeconds: 20,
        restSeconds: 10,
        cycles: 8,
        warmupSeconds: 60,
        cooldownSeconds: 60,
      ),
      WorkoutModel(
        id: Uuid().v4(),
        name: '經典HIIT',
        workSeconds: 45,
        restSeconds: 15,
        cycles: 10,
        warmupSeconds: 120,
        cooldownSeconds: 120,
      ),
      WorkoutModel(
        id: Uuid().v4(),
        name: '力量訓練',
        workSeconds: 60,
        restSeconds: 30,
        cycles: 5,
        warmupSeconds: 180,
        cooldownSeconds: 180,
      ),
    ];
  }

  // 保存訓練模式
  Future<void> saveWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = _workouts
          .map((workout) => jsonEncode(workout.toJson()))
          .toList();

      await prefs.setStringList('workouts', workoutsJson);
    } catch (e) {
      print('保存訓練時出錯: $e');
    }
  }

  // 新增訓練模式
  Future<void> addWorkout(WorkoutModel workout) async {
    final newWorkout = WorkoutModel(
      id: Uuid().v4(),
      name: workout.name,
      workSeconds: workout.workSeconds,
      restSeconds: workout.restSeconds,
      cycles: workout.cycles,
      warmupSeconds: workout.warmupSeconds,
      cooldownSeconds: workout.cooldownSeconds,
    );

    _workouts.add(newWorkout);
    notifyListeners();

    await saveWorkouts();
  }

  // 更新訓練模式
  Future<void> updateWorkout(WorkoutModel workout) async {
    final index = _workouts.indexWhere((w) => w.id == workout.id);

    if (index != -1) {
      _workouts[index] = workout;
      notifyListeners();

      await saveWorkouts();
    }
  }

  // 刪除訓練模式
  Future<void> deleteWorkout(String id) async {
    _workouts.removeWhere((workout) => workout.id == id);
    notifyListeners();

    await saveWorkouts();
  }

  // 切換收藏狀態
  Future<void> toggleFavorite(String id) async {
    final index = _workouts.indexWhere((workout) => workout.id == id);

    if (index != -1) {
      final workout = _workouts[index];
      _workouts[index] = workout.copyWith(isFavorite: !workout.isFavorite);
      notifyListeners();

      await saveWorkouts();
    }
  }

  // 獲取收藏的訓練
  List<WorkoutModel> get favoriteWorkouts =>
      _workouts.where((workout) => workout.isFavorite).toList();
}