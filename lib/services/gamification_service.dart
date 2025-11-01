import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/achievement_model.dart';
import '../models/user_stats_model.dart';
import '../constants/app_constants.dart';

/// Serviço de gamificação (pontos, níveis, conquistas)
class GamificationService {
  /// Calcula pontos por ação
  int getPointsForAction(String action) {
    switch (action) {
      case 'view_gif':
        return AppConstants.pointsPerView;
      case 'favorite':
        return AppConstants.pointsPerFavorite;
      case 'share':
        return AppConstants.pointsPerShare;
      case 'comment':
        return AppConstants.pointsPerComment;
      case 'create_collection':
        return AppConstants.pointsPerCollection;
      case 'daily_login':
        return AppConstants.pointsPerDailyLogin;
      default:
        return 0;
    }
  }

  /// Calcula o nível baseado nos pontos totais
  int calculateLevel(int totalPoints) {
    // Fórmula: nível = sqrt(pontos / 100) + 1
    final value = totalPoints / 100;
    final level = math.sqrt(value);
    return level.floor() + 1;
  }

  /// Calcula pontos necessários para o próximo nível
  int getPointsForNextLevel(int currentLevel) {
    // Fórmula: pontos = (nível^2) * 100
    return (currentLevel * currentLevel) * 100;
  }

  /// Calcula pontos atuais no nível
  int getCurrentLevelPoints(int totalPoints) {
    final level = calculateLevel(totalPoints);
    final pointsForCurrentLevel = getPointsForPreviousLevel(level);
    return totalPoints - pointsForCurrentLevel;
  }

  /// Pontos necessários para completar o nível anterior
  int getPointsForPreviousLevel(int currentLevel) {
    if (currentLevel <= 1) return 0;
    return ((currentLevel - 1) * (currentLevel - 1)) * 100;
  }

  /// Pontos necessários para avançar no nível atual
  int getPointsToNextLevel(int totalPoints) {
    final level = calculateLevel(totalPoints);
    final pointsForNextLevel = getPointsForNextLevel(level);
    final pointsForCurrentLevel = getPointsForPreviousLevel(level);
    return pointsForNextLevel - (totalPoints - pointsForCurrentLevel);
  }

  /// Retorna todas as conquistas disponíveis
  List<AchievementModel> getAllAchievements() {
    return [
      // Viewer Achievements
      const AchievementModel(
        id: 'first_gif',
        title: 'Primeira Visualização',
        description: 'Visualize seu primeiro GIF',
        icon: '👁️',
        category: AchievementCategory.viewer,
        rarity: AchievementRarity.common,
        points: 10,
        requirement: 1,
      ),
      const AchievementModel(
        id: 'gif_explorer',
        title: 'Explorador de GIFs',
        description: 'Visualize 100 GIFs',
        icon: '🔍',
        category: AchievementCategory.viewer,
        rarity: AchievementRarity.common,
        points: 50,
        requirement: 100,
      ),
      const AchievementModel(
        id: 'gif_addict',
        title: 'Viciado em GIFs',
        description: 'Visualize 1000 GIFs',
        icon: '🎬',
        category: AchievementCategory.viewer,
        rarity: AchievementRarity.rare,
        points: 200,
        requirement: 1000,
      ),
      const AchievementModel(
        id: 'gif_master',
        title: 'Mestre dos GIFs',
        description: 'Visualize 10000 GIFs',
        icon: '👑',
        category: AchievementCategory.viewer,
        rarity: AchievementRarity.legendary,
        points: 1000,
        requirement: 10000,
      ),

      // Collector Achievements
      const AchievementModel(
        id: 'first_favorite',
        title: 'Primeiro Favorito',
        description: 'Adicione seu primeiro favorito',
        icon: '⭐',
        category: AchievementCategory.collector,
        rarity: AchievementRarity.common,
        points: 10,
        requirement: 1,
      ),
      const AchievementModel(
        id: 'collector',
        title: 'Colecionador',
        description: 'Tenha 50 favoritos',
        icon: '📦',
        category: AchievementCategory.collector,
        rarity: AchievementRarity.common,
        points: 100,
        requirement: 50,
      ),
      const AchievementModel(
        id: 'master_collector',
        title: 'Colecionador Mestre',
        description: 'Tenha 500 favoritos',
        icon: '🏆',
        category: AchievementCategory.collector,
        rarity: AchievementRarity.epic,
        points: 500,
        requirement: 500,
      ),
      const AchievementModel(
        id: 'first_collection',
        title: 'Primeira Coleção',
        description: 'Crie sua primeira coleção',
        icon: '📁',
        category: AchievementCategory.collector,
        rarity: AchievementRarity.common,
        points: 25,
        requirement: 1,
      ),
      const AchievementModel(
        id: 'organizer',
        title: 'Organizador',
        description: 'Crie 10 coleções',
        icon: '🗂️',
        category: AchievementCategory.collector,
        rarity: AchievementRarity.rare,
        points: 150,
        requirement: 10,
      ),

      // Social Achievements
      const AchievementModel(
        id: 'first_share',
        title: 'Primeiro Compartilhamento',
        description: 'Compartilhe seu primeiro GIF',
        icon: '🔗',
        category: AchievementCategory.social,
        rarity: AchievementRarity.common,
        points: 15,
        requirement: 1,
      ),
      const AchievementModel(
        id: 'social_butterfly',
        title: 'Borboleta Social',
        description: 'Compartilhe 50 GIFs',
        icon: '🦋',
        category: AchievementCategory.social,
        rarity: AchievementRarity.rare,
        points: 200,
        requirement: 50,
      ),
      const AchievementModel(
        id: 'first_comment',
        title: 'Primeiro Comentário',
        description: 'Faça seu primeiro comentário',
        icon: '💬',
        category: AchievementCategory.social,
        rarity: AchievementRarity.common,
        points: 20,
        requirement: 1,
      ),

      // Explorer Achievements
      const AchievementModel(
        id: 'category_explorer',
        title: 'Explorador de Categorias',
        description: 'Explore 10 categorias diferentes',
        icon: '🗺️',
        category: AchievementCategory.explorer,
        rarity: AchievementRarity.common,
        points: 75,
        requirement: 10,
      ),
      const AchievementModel(
        id: 'search_master',
        title: 'Mestre da Busca',
        description: 'Realize 100 buscas',
        icon: '🔎',
        category: AchievementCategory.explorer,
        rarity: AchievementRarity.rare,
        points: 100,
        requirement: 100,
      ),

      // Streak Achievements
      const AchievementModel(
        id: 'week_streak',
        title: 'Sequência de 7 Dias',
        description: 'Use o app por 7 dias consecutivos',
        icon: '🔥',
        category: AchievementCategory.viewer,
        rarity: AchievementRarity.common,
        points: 100,
        requirement: 7,
      ),
      const AchievementModel(
        id: 'month_streak',
        title: 'Sequência de 30 Dias',
        description: 'Use o app por 30 dias consecutivos',
        icon: '🌟',
        category: AchievementCategory.viewer,
        rarity: AchievementRarity.epic,
        points: 500,
        requirement: 30,
      ),
      const AchievementModel(
        id: 'year_streak',
        title: 'Sequência de 365 Dias',
        description: 'Use o app por 1 ano consecutivo',
        icon: '💎',
        category: AchievementCategory.viewer,
        rarity: AchievementRarity.legendary,
        points: 5000,
        requirement: 365,
      ),
    ];
  }

  /// Verifica quais conquistas foram desbloqueadas
  List<AchievementModel> checkAchievements(
    UserStatsModel stats,
    List<String> currentUnlocked,
  ) {
    final allAchievements = getAllAchievements();
    final newlyUnlocked = <AchievementModel>[];

    for (final achievement in allAchievements) {
      if (currentUnlocked.contains(achievement.id)) continue;

      bool shouldUnlock = false;
      int progress = 0;

      switch (achievement.id) {
        // Viewer
        case 'first_gif':
        case 'gif_explorer':
        case 'gif_addict':
        case 'gif_master':
          progress = stats.gifsViewed;
          shouldUnlock = stats.gifsViewed >= achievement.requirement;
          break;

        // Collector
        case 'first_favorite':
        case 'collector':
        case 'master_collector':
          progress = stats.gifsFavorited;
          shouldUnlock = stats.gifsFavorited >= achievement.requirement;
          break;

        case 'first_collection':
        case 'organizer':
          progress = stats.collectionsCreated;
          shouldUnlock = stats.collectionsCreated >= achievement.requirement;
          break;

        // Social
        case 'first_share':
        case 'social_butterfly':
          progress = stats.gifsShared;
          shouldUnlock = stats.gifsShared >= achievement.requirement;
          break;

        case 'first_comment':
          progress = stats.commentsPosted;
          shouldUnlock = stats.commentsPosted >= achievement.requirement;
          break;

        // Explorer
        case 'category_explorer':
          progress = stats.categoryViews.length;
          shouldUnlock = stats.categoryViews.length >= achievement.requirement;
          break;

        // Streak
        case 'week_streak':
        case 'month_streak':
        case 'year_streak':
          progress = stats.daysStreak;
          shouldUnlock = stats.daysStreak >= achievement.requirement;
          break;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(
          achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            currentProgress: progress,
          ),
        );
      }
    }

    return newlyUnlocked;
  }

  /// Atualiza o progresso das conquistas
  List<AchievementModel> updateAchievementsProgress(
    UserStatsModel stats,
    List<String> unlockedIds,
  ) {
    final allAchievements = getAllAchievements();
    final updated = <AchievementModel>[];

    for (final achievement in allAchievements) {
      int progress = 0;
      bool isUnlocked = unlockedIds.contains(achievement.id);

      switch (achievement.id) {
        case 'first_gif':
        case 'gif_explorer':
        case 'gif_addict':
        case 'gif_master':
          progress = stats.gifsViewed;
          break;

        case 'first_favorite':
        case 'collector':
        case 'master_collector':
          progress = stats.gifsFavorited;
          break;

        case 'first_collection':
        case 'organizer':
          progress = stats.collectionsCreated;
          break;

        case 'first_share':
        case 'social_butterfly':
          progress = stats.gifsShared;
          break;

        case 'first_comment':
          progress = stats.commentsPosted;
          break;

        case 'category_explorer':
          progress = stats.categoryViews.length;
          break;

        case 'week_streak':
        case 'month_streak':
        case 'year_streak':
          progress = stats.daysStreak;
          break;
      }

      updated.add(
        achievement.copyWith(isUnlocked: isUnlocked, currentProgress: progress),
      );
    }

    return updated;
  }
}
