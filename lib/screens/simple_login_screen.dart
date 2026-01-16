import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_sync_service.dart'; // ✅ AGGIUNTO

class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _savedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadSavedUsers();
  }

  Future<void> _loadSavedUsers() async {
    final box = await LocalStorageService.getUserBox();
    final users = <Map<String, dynamic>>[];
    
    for (var key in box.keys) {
      if (key.toString().startsWith('user_')) {
        final userData = box.get(key) as Map<dynamic, dynamic>;
        users.add({
          'id': key,
          'name': userData['name'],
          'age': userData['age'],
        });
      }
    }
    
    setState(() {
      _savedUsers = users;
    });
  }

  Future<void> _handleLogin() async {
    if (_nameController.text.isEmpty || _pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Inserisci nome e PIN';
      });
      return;
    }

    if (_pinController.text.length != 4) {
      setState(() {
        _errorMessage = 'Il PIN deve essere di 4 cifre';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final box = await LocalStorageService.getUserBox();
      
      // Find user by name
      String? foundUserId;
      for (var key in box.keys) {
        if (key.toString().startsWith('user_')) {
          final userData = box.get(key) as Map<dynamic, dynamic>;
          if (userData['name'] == _nameController.text) {
            foundUserId = key;
            break;
          }
        }
      }

      if (foundUserId == null) {
        setState(() {
          _errorMessage = 'Utente non trovato';
          _isLoading = false;
        });
        return;
      }

      final userData = box.get(foundUserId) as Map<dynamic, dynamic>;
      
      // Check PIN
      if (userData['pin'] != _pinController.text) {
        setState(() {
          _errorMessage = 'PIN errato';
          _isLoading = false;
        });
        return;
      }

      // Load user profile
      final profile = UserProfile.fromMap(Map<String, dynamic>.from(userData));
      
      if (!mounted) return;
      
      // Update provider
      Provider.of<UserProfileProvider>(context, listen: false)
          .setProfile(profile);

      // Save as current profile (local)
      await LocalStorageService.saveUserProfile(profile);

      // ✅ SYNC TO FIREBASE
      try {
        await FirebaseSyncService.syncUserProfile(profile);
        debugPrint('✅ Profile synced to Firebase after login');
      } catch (e) {
        debugPrint('⚠️ Firebase sync failed (offline?): $e');
        // Continua comunque - funziona offline
      }

      if (!mounted) return;
      
      // Navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore durante il login: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || 
        _ageController.text.isEmpty || 
        _pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Compila tutti i campi';
      });
      return;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age < 1 || age > 120) {
      setState(() {
        _errorMessage = 'Età non valida';
      });
      return;
    }

    if (_pinController.text.length != 4) {
      setState(() {
        _errorMessage = 'Il PIN deve essere di 4 cifre';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final box = await LocalStorageService.getUserBox();
      
      // ✅ Check if user already exists LOCALLY
      for (var key in box.keys) {
        if (key.toString().startsWith('user_')) {
          final userData = box.get(key) as Map<dynamic, dynamic>;
          if (userData['name'] == _nameController.text) {
            setState(() {
              _errorMessage = 'Nome utente già esistente (locale)';
              _isLoading = false;
            });
            return;
          }
        }
      }

      // ✅ Check if user already exists ON FIREBASE
      try {
        final existingUsers = await FirebaseSyncService.getAllUsers();
        final duplicate = existingUsers.any((user) => 
          user['name'] == _nameController.text
        );
        
        if (duplicate) {
          setState(() {
            _errorMessage = 'Nome utente già registrato su altro dispositivo';
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('⚠️ Firebase check failed (offline?): $e');
        // Continua comunque - funziona offline
      }

      // Create new user profile
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final profile = UserProfile(
        id: userId,
        name: _nameController.text,
        age: age,
        startDate: DateTime.now(),
      );

      // Save with PIN (local)
      final userDataWithPin = profile.toMap();
      userDataWithPin['pin'] = _pinController.text;
      
      await box.put(userId, userDataWithPin);
      
      if (!mounted) return;
      
      // Update provider
      Provider.of<UserProfileProvider>(context, listen: false)
          .setProfile(profile);

      // Save as current profile (local)
      await LocalStorageService.saveUserProfile(profile);

      // ✅ SYNC TO FIREBASE
      try {
        await FirebaseSyncService.syncUserProfile(profile);
        debugPrint('✅ New user synced to Firebase');
      } catch (e) {
        debugPrint('⚠️ Firebase sync failed (offline?): $e');
        // Continua comunque - funziona offline
      }

      if (!mounted) return;
      
      // Navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore durante la registrazione: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.psychology,
                          size: 60,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Brain Boost',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? 'Accedi al tuo account' : 'Crea un nuovo account',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Saved users (only for login)
                      if (_isLogin && _savedUsers.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          children: _savedUsers.map((user) {
                            return ChoiceChip(
                              label: Text('${user['name']} (${user['age']} anni)'),
                              selected: _nameController.text == user['name'],
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _nameController.text = user['name'];
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Name field
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Age field (only for register)
                      if (!_isLogin) ...[
                        TextField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: 'Età',
                            prefixIcon: const Icon(Icons.cake),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // PIN field
                      TextField(
                        controller: _pinController,
                        decoration: InputDecoration(
                          labelText: 'PIN (4 cifre)',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 8),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Action button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading 
                              ? null 
                              : (_isLogin ? _handleLogin : _handleRegister),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Accedi' : 'Registrati',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Toggle login/register
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _errorMessage = null;
                                  _pinController.clear();
                                  if (!_isLogin) {
                                    _nameController.clear();
                                  }
                                });
                              },
                        child: Text(
                          _isLogin
                              ? 'Non hai un account? Registrati'
                              : 'Hai già un account? Accedi',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
