// models/workout_model.dart - 訓練模式數據模型
class WorkoutModel {
  final String id;
  final String name;
  int workSeconds;
  int restSeconds;
  int cycles;
  int warmupSeconds;
  int cooldownSeconds;
  bool isFavorite;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.workSeconds,
    required this.restSeconds,
    required this.cycles,
    this.warmupSeconds = 0,
    this.cooldownSeconds = 0,
    this.isFavorite = false,
  });

  // 從JSON創建模型
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      name: json['name'],
      workSeconds: json['workSeconds'],
      restSeconds: json['restSeconds'],
      cycles: json['cycles'],
      warmupSeconds: json['warmupSeconds'] ?? 0,
      cooldownSeconds: json['cooldownSeconds'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'cycles': cycles,
      'warmupSeconds': warmupSeconds,
      'cooldownSeconds': cooldownSeconds,
      'isFavorite': isFavorite,
    };
  }

  // 複製並修改部分屬性
  WorkoutModel copyWith({
    String? name,
    int? workSeconds,
    int? restSeconds,
    int? cycles,
    int? warmupSeconds,
    int? cooldownSeconds,
    bool? isFavorite,
  }) {
    return WorkoutModel(
      id: id,
      name: name ?? this.name,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      cycles: cycles ?? this.cycles,
      warmupSeconds: warmupSeconds ?? this.warmupSeconds,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
