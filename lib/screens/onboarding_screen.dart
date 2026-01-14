import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Schermata onboarding per nuovi utenti
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.psychology,
      title: 'Benvenuto in Brain Boost',
      description: 'Allena la tua mente con 7 giochi cognitivi scientificamente validati',
      color: Colors.blue,
    ),
    OnboardingPage(
      icon: Icons.emoji_events,
      title: 'Sistema Gamification',
      description: 'Guadagna XP, sali di livello e sblocca badge completando le sessioni',
      color: Colors.orange,
    ),
    OnboardingPage(
      icon: Icons.analytics,
      title: 'Traccia i Progressi',
      description: 'Visualizza statistiche dettagliate e grafici delle tue performance',
      color: Colors.green,
    ),
    OnboardingPage(
      icon: Icons.assessment,
      title: 'Assessment Certificato',
      description: 'Completa il test iniziale per ricevere una valutazione cognitiva certificata',
      color: Colors.purple,
    ),
    OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'AI Adattivo',
      description: 'Il sistema regola automaticamente la difficoltà in base alle tue performance',
      color: Colors.red,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Salta'),
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Indietro'),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Avanti' : 'Inizia',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 40),
          
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Check se mostrare onboarding
  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_completed') ?? false);
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
