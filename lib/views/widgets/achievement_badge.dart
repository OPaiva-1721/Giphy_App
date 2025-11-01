import 'package:flutter/material.dart';
import '../../models/achievement_model.dart';
import '../../constants/app_colors.dart';
import '../../utils/helpers.dart';

/// Badge de conquista
class AchievementBadge extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !achievement.isUnlocked;
    final rarityColor = Color(Helpers.getRarityColor(achievement.rarity.name));

    return Card(
      elevation: achievement.isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: achievement.isUnlocked
                ? Border.all(color: rarityColor, width: 2)
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLocked
                          ? Colors.grey.withOpacity(0.3)
                          : rarityColor.withOpacity(0.2),
                    ),
                  ),
                  Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 32,
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                  if (isLocked)
                    const Icon(
                      Icons.lock,
                      size: 24,
                      color: Colors.grey,
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Description
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isLocked 
                      ? Colors.grey 
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Progress or Points
              if (isLocked)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: achievement.progressPercentage,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement.currentProgress}/${achievement.requirement}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${achievement.points} pts',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: rarityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

