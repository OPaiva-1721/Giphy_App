import 'package:flutter/material.dart';
import '../../models/user_stats_model.dart';

class StatsDialog extends StatelessWidget {
  final UserStatsModel userStats;
  final String Function(String) getAchievementName;

  const StatsDialog({
    super.key,
    required this.userStats,
    required this.getAchievementName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suas Estatísticas'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pontos: ${userStats.points}'),
          Text('GIFs visualizados: ${userStats.gifsViewed}'),
          Text('Favoritos: ${userStats.favoritesCount}'),
          Text('Comentários: ${userStats.commentsCount}'),
          Text('Reações dadas: ${userStats.reactionsGiven}'),
          const SizedBox(height: 16),
          if (userStats.achievements.isNotEmpty) ...[
            const Text('Conquistas:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...userStats.achievements.map((achievement) => Text(
              '🏆 ${getAchievementName(achievement)}',
              style: const TextStyle(fontSize: 12),
            )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
