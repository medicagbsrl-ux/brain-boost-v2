import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_profile_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // Login
        await AuthService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
        // Carica profilo dopo login
        final userId = await AuthService.getCurrentUserId();
        if (userId != null && mounted) {
          final profile = await AuthService.loadUserProfile(userId);
          if (profile != null) {
            final provider = Provider.of<UserProfileProvider>(context, listen: false);
            await provider.setProfile(profile);
          }
        }
      } else {
        // Registrazione
        await AuthService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
        );
        
        // Carica profilo dopo registrazione
        final userId = await AuthService.getCurrentUserId();
        if (userId != null && mounted) {
          final profile = await AuthService.loadUserProfile(userId);
          if (profile != null) {
            final provider = Provider.of<UserProfileProvider>(context, listen: false);
            await provider.setProfile(profile);
          }
        }
      }
      
      // Successo - ricarica provider per aggiornare UI
      if (mounted) {
        final provider = Provider.of<UserProfileProvider>(context, listen: false);
        await provider.reloadProfile();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore imprevisto. Riprova.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email non trovata. Registrati prima.';
      case 'wrong-password':
        return 'Password errata.';
      case 'email-already-in-use':
        return 'Email già registrata. Effettua il login.';
      case 'weak-password':
        return 'Password troppo debole. Usa almeno 6 caratteri.';
      case 'invalid-email':
        return 'Email non valida.';
      case 'network-request-failed':
        return 'Errore di rete. Controlla la connessione.';
      default:
        return 'Errore: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo e Titolo
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Brain Boost',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                    ? 'Accedi al tuo account' 
                    : 'Crea il tuo account',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nome (solo registrazione)
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome completo',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (!_isLogin && (value == null || value.isEmpty)) {
                              return 'Inserisci il tuo nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Età (solo registrazione)
                        TextFormField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: 'Età',
                            prefixIcon: const Icon(Icons.cake),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (!_isLogin) {
                              if (value == null || value.isEmpty) {
                                return 'Inserisci la tua età';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 1 || age > 120) {
                                return 'Età non valida';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci la tua email';
                          }
                          if (!value.contains('@')) {
                            return 'Email non valida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci la password';
                          }
                          if (!_isLogin && value.length < 6) {
                            return 'Password deve avere almeno 6 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Messaggio di errore
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Pulsante Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isLogin ? 'ACCEDI' : 'REGISTRATI',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Login/Registrazione
                      TextButton(
                        onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _errorMessage = null;
                              });
                            },
                        child: Text(
                          _isLogin
                            ? 'Non hai un account? Registrati'
                            : 'Hai già un account? Accedi',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ],
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
