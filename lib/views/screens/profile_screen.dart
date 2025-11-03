import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/gif_viewmodel.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../utils/helpers.dart';
import '../widgets/stat_card.dart';
import '../widgets/achievement_badge.dart';
import 'debug_screen.dart';

/// Tela de perfil e estatísticas
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await userViewModel.refresh();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            userViewModel.user.name
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userViewModel.user.name ?? 'Usuário',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userViewModel.user.email != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              userViewModel.user.email!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Level progress
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${AppStrings.level} ${userViewModel.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${Helpers.formatNumber(userViewModel.stats.totalPoints)} pts',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: userViewModel.progressToNextLevel,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Faltam ${Helpers.formatNumber(userViewModel.pointsToNextLevel)} pontos para o nível ${userViewModel.level + 1}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics
                const Text(
                  AppStrings.statistics,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: AppStrings.gifsViewed,
                      value: userViewModel.stats.gifsViewed,
                      icon: Icons.visibility,
                      color: AppColors.primary,
                    ),
                    StatCard(
                      title: AppStrings.gifsShared,
                      value: userViewModel.stats.gifsShared,
                      icon: Icons.share,
                      color: AppColors.accent,
                    ),
                    StatCard(
                      title: AppStrings.favorites,
                      value: userViewModel.stats.gifsFavorited,
                      icon: Icons.favorite,
                      color: Colors.red,
                    ),
                    StatCard(
                      title: AppStrings.myCollections,
                      value: userViewModel.stats.collectionsCreated,
                      icon: Icons.folder,
                      color: AppColors.secondary,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Achievements
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.achievements,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                      },
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (userViewModel.unlockedAchievements.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Continue usando o app para desbloquear conquistas!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userViewModel.unlockedAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement =
                            userViewModel.unlockedAchievements[index];
                        return SizedBox(
                          width: 150,
                          child: AchievementBadge(achievement: achievement),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppStrings.appearance,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          // Theme selector
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, _) {
              return ListTile(
                leading: const Icon(Icons.palette),
                title: const Text(AppStrings.theme),
                subtitle: Text(_getThemeModeName(themeViewModel.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemeDialog(context, themeViewModel);
                },
              );
            },
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Preferências',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          // Auto-shuffle
          Consumer<GifViewModel>(
            builder: (context, gifViewModel, _) {
              return SwitchListTile(
                secondary: const Icon(Icons.shuffle),
                title: const Text(AppStrings.autoShuffle),
                subtitle: const Text('Busca novos GIFs automaticamente'),
                value: gifViewModel.autoShuffle,
                onChanged: (_) => gifViewModel.toggleAutoShuffle(),
              );
            },
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Debug',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Logs / Debug'),
            subtitle: const Text('Ver status do Firebase e API Key'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DebugScreen(),
                ),
              );
            },
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppStrings.about,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(AppStrings.version),
            subtitle: const Text('2.0.0'),
          ),

          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text(AppStrings.privacyPolicy),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
            },
          ),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text(AppStrings.termsOfService),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
            },
          ),

          // Powered by GIPHY
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 32, 16, 24),
            child: Center(
              child: Text(
                'Powered by GIPHY',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppStrings.themeLight;
      case ThemeMode.dark:
        return AppStrings.themeDark;
      case ThemeMode.system:
        return AppStrings.themeSystem;
    }
  }

  void _showThemeDialog(BuildContext context, ThemeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text(AppStrings.themeLight),
              value: ThemeMode.light,
              groupValue: viewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text(AppStrings.themeDark),
              value: ThemeMode.dark,
              groupValue: viewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text(AppStrings.themeSystem),
              value: ThemeMode.system,
              groupValue: viewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
