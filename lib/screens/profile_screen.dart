import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final profile = profileProvider.currentProfile;
    final l10n = AppLocalizations.of(context)!;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(l10n.translate('profile_title')),
              centerTitle: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Profile Header
                  _buildProfileHeader(context, profile),
                  const SizedBox(height: 32),

                  // Settings
                  _buildSectionTitle(context, l10n.translate('profile_settings')),
                  const SizedBox(height: 16),
                  _buildThemeSelector(context, profile, profileProvider, l10n),
                  const SizedBox(height: 12),
                  _buildTextSizeSelector(context, profile, profileProvider, l10n),
                  const SizedBox(height: 12),
                  _buildLanguageSelector(context, profile, profileProvider, l10n),
                  const SizedBox(height: 12),
                  _buildContrastSelector(context, profile, profileProvider, l10n),
                  const SizedBox(height: 32),

                  // Session Preferences
                  _buildSectionTitle(context, 'Preferenze Sessione'),
                  const SizedBox(height: 16),
                  _buildSessionDurationCard(context, profile, profileProvider, l10n),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${profile.age} anni',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat(
                  context,
                  'Livello',
                  profile.currentLevel.toString(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildProfileStat(
                  context,
                  'Punti',
                  profile.totalPoints.toString(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildProfileStat(
                  context,
                  'Sessioni',
                  profile.sessionsCompleted.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    dynamic profile,
    UserProfileProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.translate('theme'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildThemeChip(
                  context,
                  'professional',
                  l10n.translate('theme_professional'),
                  profile.theme == 'professional',
                  provider,
                ),
                _buildThemeChip(
                  context,
                  'gamified',
                  l10n.translate('theme_gamified'),
                  profile.theme == 'gamified',
                  provider,
                ),
                _buildThemeChip(
                  context,
                  'minimal',
                  l10n.translate('theme_minimal'),
                  profile.theme == 'minimal',
                  provider,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChip(
    BuildContext context,
    String value,
    String label,
    bool selected,
    UserProfileProvider provider,
  ) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool value) {
        if (value) {
          provider.updateTheme(value ? label.toLowerCase() : 'professional');
        }
      },
    );
  }

  Widget _buildTextSizeSelector(
    BuildContext context,
    dynamic profile,
    UserProfileProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_size, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.translate('text_size'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'normal',
                  label: Text(l10n.translate('text_normal')),
                ),
                ButtonSegment(
                  value: 'large',
                  label: Text(l10n.translate('text_large')),
                ),
                ButtonSegment(
                  value: 'extra_large',
                  label: Text(l10n.translate('text_extra_large')),
                ),
              ],
              selected: {profile.textSize},
              onSelectionChanged: (Set<String> selection) {
                provider.updateTextSize(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    dynamic profile,
    UserProfileProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.translate('language'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            DropdownButton<String>(
              value: profile.language,
              items: const [
                DropdownMenuItem(value: 'it', child: Text('🇮🇹 Italiano')),
                DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
                DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
                DropdownMenuItem(value: 'de', child: Text('🇩🇪 Deutsch')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  provider.updateLanguage(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContrastSelector(
    BuildContext context,
    dynamic profile,
    UserProfileProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.contrast, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('contrast'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    profile.contrast == 'high'
                        ? l10n.translate('contrast_high')
                        : l10n.translate('contrast_standard'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: profile.contrast == 'high',
              onChanged: (bool value) {
                provider.updateContrast(value ? 'high' : 'standard');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDurationCard(
    BuildContext context,
    dynamic profile,
    UserProfileProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.translate('session_duration'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 15, 20, 30].map((duration) {
                return ChoiceChip(
                  label: Text('$duration min'),
                  selected: profile.sessionDuration == duration,
                  onSelected: (bool selected) {
                    if (selected) {
                      provider.updateSessionDuration(duration);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
