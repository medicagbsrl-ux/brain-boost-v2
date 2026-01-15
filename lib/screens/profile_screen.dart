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
                  const SizedBox(height: 32),

                  // Notifications
                  _buildSectionTitle(context, 'Notifiche e Promemoria'),
                  const SizedBox(height: 16),
                  _buildNotificationSettings(context, profile, profileProvider),
                  const SizedBox(height: 32),

                  // Logout button
                  _buildLogoutButton(context, profileProvider),
                  const SizedBox(height: 24),
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
      onSelected: (bool isSelected) {
        if (isSelected) {
          provider.updateTheme(value); // Use the theme value (professional/gamified/minimal)
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

  Widget _buildNotificationSettings(
    BuildContext context,
    dynamic profile,
    UserProfileProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active),
                const SizedBox(width: 12),
                Text(
                  'Promemoria Quotidiano',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ricevi un promemoria per allenarti ogni giorno',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profile.remindersEnabled ? 'Attivo' : 'Disattivato',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: profile.remindersEnabled
                            ? Colors.green
                            : Colors.grey,
                      ),
                ),
                Switch(
                  value: profile.remindersEnabled ?? false,
                  onChanged: (bool value) async {
                    if (value) {
                      // Show time picker
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 18, minute: 0),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context),
                            child: child!,
                          );
                        },
                      );

                      if (pickedTime != null) {
                        await provider.setDailyReminder(
                          true,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Promemoria attivato alle ${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          );
                        }
                      }
                    } else {
                      await provider.setDailyReminder(false, 0, 0);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Promemoria disattivato'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Riceverai anche notifiche per livelli, achievement e streak!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserProfileProvider provider) {
    return Card(
      color: Colors.red.shade50,
      child: InkWell(
        onTap: () => _showLogoutDialog(context, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Esci dall\'account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    Text(
                      'Disconnettiti dal tuo profilo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.red.shade700),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, UserProfileProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma uscita'),
        content: const Text('Sei sicuro di voler uscire dal tuo account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Esci'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await provider.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }
}
