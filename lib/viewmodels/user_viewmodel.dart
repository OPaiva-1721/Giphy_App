import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/user_stats_model.dart';
import '../models/achievement_model.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';
import '../services/analytics_service.dart';

/// ViewModel para usuário
class UserViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final GamificationService _gamificationService = GamificationService();
  final AnalyticsService _analyticsService = AnalyticsService();

  UserModel _user = UserModel.empty();
  UserStatsModel _stats = UserStatsModel.empty();
  List<AchievementModel> _achievements = [];
  int _level = 1;
  int _pointsToNextLevel = 100;

  // Getters
  UserModel get user => _user;
  UserStatsModel get stats => _stats;
  List<AchievementModel> get achievements => _achievements;
  int get level => _level;
  int get pointsToNextLevel => _pointsToNextLevel;

  List<AchievementModel> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  List<AchievementModel> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();

  double get progressToNextLevel {
    final currentLevelPoints = _gamificationService.getCurrentLevelPoints(
      _stats.totalPoints,
    );
    final pointsNeeded = _pointsToNextLevel;
    return (currentLevelPoints / pointsNeeded).clamp(0.0, 1.0);
  }

  /// Inicializa
  Future<void> initialize() async {
    await _storageService.init();
    await _loadUser();
    await _loadStats();
    _updateLevel();
    _updateAchievements();
    await _checkDailyStreak();
  }

  /// Atualiza dados do usuário
  Future<void> refresh() async {
    await _loadUser();
    await _loadStats();
    _updateLevel();
    _updateAchievements();
    await _checkDailyStreak();
    notifyListeners();
  }

  /// Carrega usuário
  Future<void> _loadUser() async {
    _user = UserModel.empty();
    notifyListeners();
  }

  /// Carrega estatísticas
  Future<void> _loadStats() async {
    _stats = _storageService.getUserStats() ?? UserStatsModel.empty();
    notifyListeners();
  }

  /// Atualiza estatísticas
  Future<void> updateStats(UserStatsModel newStats) async {
    final oldLevel = _level;

    _stats = newStats;
    await _storageService.saveUserStats(_stats);

    _updateLevel();

    // Verifica se subiu de nível
    if (_level > oldLevel) {
      await _analyticsService.logLevelUp(_level);
    }

    // Verifica conquistas
    final newAchievements = _gamificationService.checkAchievements(
      _stats,
      _stats.unlockedAchievements,
    );

    if (newAchievements.isNotEmpty) {
      for (final achievement in newAchievements) {
        _stats = _stats.copyWith(
          unlockedAchievements: [
            ..._stats.unlockedAchievements,
            achievement.id,
          ],
        );
        await _analyticsService.logAchievementUnlocked(achievement.id);
      }
      await _storageService.saveUserStats(_stats);
    }

    _updateAchievements();
    notifyListeners();
  }

  /// Atualiza nível
  void _updateLevel() {
    _level = _gamificationService.calculateLevel(_stats.totalPoints);
    _pointsToNextLevel = _gamificationService.getPointsToNextLevel(
      _stats.totalPoints,
    );
  }

  /// Atualiza conquistas
  void _updateAchievements() {
    _achievements = _gamificationService.updateAchievementsProgress(
      _stats,
      _stats.unlockedAchievements,
    );
  }

  /// Verifica sequência diária
  Future<void> _checkDailyStreak() async {
    final now = DateTime.now();
    final lastActive = _stats.lastActiveDate;

    if (lastActive == null) {
      // Primeira vez
      _stats = _stats.copyWith(daysStreak: 1, lastActiveDate: now);
      await _storageService.saveUserStats(_stats);
    } else {
      final difference = now.difference(lastActive).inDays;

      if (difference == 0) {
        // Mesmo dia, não faz nada
        return;
      } else if (difference == 1) {
        // Dia consecutivo
        _stats = _stats.copyWith(
          daysStreak: _stats.daysStreak + 1,
          lastActiveDate: now,
          totalPoints:
              _stats.totalPoints +
              _gamificationService.getPointsForAction('daily_login'),
        );
        await _storageService.saveUserStats(_stats);
      } else {
        // Quebrou a sequência
        _stats = _stats.copyWith(daysStreak: 1, lastActiveDate: now);
        await _storageService.saveUserStats(_stats);
      }
    }

    await updateStats(_stats);
  }

  /// Adiciona pontos
  Future<void> addPoints(String action) async {
    final points = _gamificationService.getPointsForAction(action);
    _stats = _stats.copyWith(totalPoints: _stats.totalPoints + points);
    await updateStats(_stats);
  }

  /// Incrementa contador de GIFs visualizados
  Future<void> incrementGifsViewed() async {
    _stats = _stats.copyWith(gifsViewed: _stats.gifsViewed + 1);
    await updateStats(_stats);
  }

  /// Incrementa contador de GIFs compartilhados
  Future<void> incrementGifsShared() async {
    _stats = _stats.copyWith(gifsShared: _stats.gifsShared + 1);
    await updateStats(_stats);
  }

  /// Incrementa contador de GIFs favoritados
  Future<void> incrementGifsFavorited() async {
    _stats = _stats.copyWith(gifsFavorited: _stats.gifsFavorited + 1);
    await updateStats(_stats);
  }

  /// Incrementa contador de coleções criadas
  Future<void> incrementCollectionsCreated() async {
    _stats = _stats.copyWith(collectionsCreated: _stats.collectionsCreated + 1);
    await updateStats(_stats);
  }

  /// Adiciona visualização de categoria
  Future<void> addCategoryView(String category) async {
    final categoryViews = Map<String, int>.from(_stats.categoryViews);
    categoryViews[category] = (categoryViews[category] ?? 0) + 1;

    _stats = _stats.copyWith(categoryViews: categoryViews);
    await updateStats(_stats);
  }

  /// Retorna categorias mais visualizadas
  List<MapEntry<String, int>> getTopCategories({int limit = 5}) {
    final entries = _stats.categoryViews.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }
}
