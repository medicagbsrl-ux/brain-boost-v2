import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/user_profile_provider.dart';
import 'screens/home_screen.dart';
import 'screens/games_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/simple_login_screen.dart';
import 'themes/app_themes.dart';
import 'l10n/app_localizations.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive storage
  await LocalStorageService.initialize();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],
      child: const BrainBoostApp(),
    ),
  );
}

class BrainBoostApp extends StatelessWidget {
  const BrainBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final profile = profileProvider.currentProfile;
        final themeName = profile?.theme ?? 'professional';
        final locale = Locale(profile?.language ?? 'it');

        // Get base theme
        ThemeData baseTheme = AppThemes.getThemeForProfile(context, themeName);

        // Adjust text size if needed
        if (profile != null && profile.textSize != 'normal') {
          baseTheme = baseTheme.copyWith(
            textTheme: AppThemes.adjustTextSize(baseTheme.textTheme, profile.textSize),
          );
        }

        return MaterialApp(
          title: 'Brain Boost',
          debugShowCheckedModeBanner: false,
          theme: baseTheme,
          locale: locale,
          supportedLocales: const [
            Locale('it'),
            Locale('en'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            '/home': (context) => const MainScreen(),
            '/profile': (context) => const ProfileScreen(), // ✅ Aggiunto
          },
          home: profile == null ? const SimpleLoginScreen() : const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(tabController: _tabController),
            const GamesScreen(),
            const ProgressScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            _tabController.animateTo(index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n?.translate('nav_home') ?? 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.sports_esports_outlined),
              selectedIcon: const Icon(Icons.sports_esports),
              label: l10n?.translate('nav_games') ?? 'Giochi',
            ),
            NavigationDestination(
              icon: const Icon(Icons.trending_up_outlined),
              selectedIcon: const Icon(Icons.trending_up),
              label: l10n?.translate('nav_progress') ?? 'Progressi',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person),
              label: l10n?.translate('nav_profile') ?? 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
}
