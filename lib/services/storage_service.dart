import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';
import 'dart:convert';

class StorageService {
  // 獲取 SharedPreferences 實例
  static Future<SharedPreferences> _getPreferences() async {
    return await SharedPreferences.getInstance();
  }

  // 保存訓練模式到本地
  static Future<void> saveWorkouts(List<WorkoutModel> workouts) async {
    final prefs = await _getPreferences();

    // 將 List<WorkoutModel> 轉換為 JSON 字符串
    List<String> workoutsJson = workouts.map((workout) {
      return jsonEncode(workout.toJson());
    }).toList();

    // 保存至 SharedPreferences
    await prefs.setStringList('workouts', workoutsJson);
  }

  // 讀取訓練模式從本地
  static Future<List<WorkoutModel>> loadWorkouts() async {
    final prefs = await _getPreferences();

    // 讀取保存的 workouts 字符串列表
    List<String> workoutsJson = prefs.getStringList('workouts') ?? [];

    // 將 JSON 字符串轉換為 List<WorkoutModel>
    return workoutsJson.map((json) {
      return WorkoutModel.fromJson(jsonDecode(json));
    }).toList();
  }

  // 更新訓練模式到本地
  static Future<void> updateWorkout(WorkoutModel workout) async {
    final prefs = await _getPreferences();
    List<String> workoutsJson = prefs.getStringList('workouts') ?? [];

    // 找到要更新的訓練模式
    int index = workoutsJson.indexWhere((json) {
      return WorkoutModel.fromJson(jsonDecode(json)).id == workout.id;
    });

    // 更新訓練模式
    if (index != -1) {
      workoutsJson[index] = jsonEncode(workout.toJson());
      await prefs.setStringList('workouts', workoutsJson);
    }
  }

  // 刪除訓練模式
  static Future<void> deleteWorkout(String id) async {
    final prefs = await _getPreferences();
    List<String> workoutsJson = prefs.getStringList('workouts') ?? [];

    // 刪除指定的訓練模式
    workoutsJson.removeWhere((json) {
      return WorkoutModel.fromJson(jsonDecode(json)).id == id;
    });

    // 保存更新後的 workouts 列表
    await prefs.setStringList('workouts', workoutsJson);
  }
}