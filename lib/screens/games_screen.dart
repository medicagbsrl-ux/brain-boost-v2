import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../themes/app_themes.dart';
import '../providers/user_profile_provider.dart';
import '../games/memory_match/memory_match_game.dart';
import '../games/stroop_test/stroop_test_game.dart';
import '../games/reaction_time/reaction_time_game.dart';
import '../games/number_sequence/number_sequence_game.dart';
import '../games/pattern_recognition/pattern_recognition_game.dart';
import '../games/word_association/word_association_game.dart';
import '../games/spatial_memory/spatial_memory_game.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final games = [
      {
        'id': 'memory_match',
        'name': l10n.translate('game_memory_match'),
        'desc': l10n.translate('game_memory_match_desc'),
        'icon': Icons.grid_view,
        'color': AppThemes.cognitiveColors['memory']!,
        'domain': 'memory',
      },
      {
        'id': 'number_sequence',
        'name': l10n.translate('game_number_sequence'),
        'desc': l10n.translate('game_number_sequence_desc'),
        'icon': Icons.format_list_numbered,
        'color': AppThemes.cognitiveColors['memory']!,
        'domain': 'memory',
      },
      {
        'id': 'stroop',
        'name': l10n.translate('game_stroop'),
        'desc': l10n.translate('game_stroop_desc'),
        'icon': Icons.palette,
        'color': AppThemes.cognitiveColors['attention']!,
        'domain': 'attention',
      },
      {
        'id': 'pattern',
        'name': l10n.translate('game_pattern'),
        'desc': l10n.translate('game_pattern_desc'),
        'icon': Icons.category,
        'color': AppThemes.cognitiveColors['executive']!,
        'domain': 'executive',
      },
      {
        'id': 'reaction',
        'name': l10n.translate('game_reaction'),
        'desc': l10n.translate('game_reaction_desc'),
        'icon': Icons.touch_app,
        'color': AppThemes.cognitiveColors['speed']!,
        'domain': 'speed',
      },
      {
        'id': 'word_association',
        'name': l10n.translate('game_word_association'),
        'desc': l10n.translate('game_word_association_desc'),
        'icon': Icons.link,
        'color': AppThemes.cognitiveColors['language']!,
        'domain': 'language',
      },
      {
        'id': 'spatial',
        'name': l10n.translate('game_spatial'),
        'desc': l10n.translate('game_spatial_desc'),
        'icon': Icons.location_on,
        'color': AppThemes.cognitiveColors['spatial']!,
        'domain': 'spatial',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(l10n.translate('games_title')),
              centerTitle: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = games[index];
                    return _buildGameCard(context, game, l10n);
                  },
                  childCount: games.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game, AppLocalizations l10n) {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final userId = profileProvider.currentProfile?.id ?? 'demo_user';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _launchGame(context, game['id'] as String, userId);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (game['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  game['icon'] as IconData,
                  color: game['color'] as Color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game['desc'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_filled,
                color: game['color'] as Color,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchGame(BuildContext context, String gameId, String userId) {
    Widget gameScreen;

    switch (gameId) {
      case 'memory_match':
        gameScreen = MemoryMatchGame(userId: userId, level: 1);
        break;
      case 'number_sequence':
        gameScreen = NumberSequenceGame(userId: userId, level: 1);
        break;
      case 'stroop':
        gameScreen = StroopTestGame(userId: userId, level: 1);
        break;
      case 'pattern':
        gameScreen = PatternRecognitionGame(userId: userId, level: 1);
        break;
      case 'reaction':
        gameScreen = ReactionTimeGame(userId: userId, level: 1);
        break;
      case 'word_association':
        gameScreen = WordAssociationGame(userId: userId, level: 1);
        break;
      case 'spatial':
        gameScreen = SpatialMemoryGame(userId: userId, level: 1);
        break;
      default:
        _showGameComingSoon(context, gameId);
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreen),
    );
  }

  void _showGameComingSoon(BuildContext context, String gameName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gameName),
        content: const Text('Gioco in fase di sviluppo.\nSarà disponibile a breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
