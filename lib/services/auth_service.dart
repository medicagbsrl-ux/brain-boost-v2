import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'local_storage_service.dart';

class AuthService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static bool _firebaseAvailable = false;

  // Inizializza Firebase se disponibile
  static Future<void> initialize() async {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _firebaseAvailable = true;
      if (kDebugMode) {
        debugPrint('✅ Firebase initialized successfully');
      }
    } catch (e) {
      _firebaseAvailable = false;
      if (kDebugMode) {
        debugPrint('⚠️ Firebase not available, using local auth: $e');
      }
    }
  }

  // Stream dell'utente corrente (locale o Firebase)
  static Stream<User?> get authStateChanges {
    if (_firebaseAvailable && _auth != null) {
      return _auth!.authStateChanges();
    }
    // Modalità locale: stream sempre null (gestito da UserProfileProvider)
    return Stream.value(null);
  }

  // Utente corrente
  static User? get currentUser => _firebaseAvailable ? _auth?.currentUser : null;

  // Controlla se utente è loggato (locale)
  static Future<bool> isLocalUserLoggedIn() async {
    final box = await LocalStorageService.getUserBox();
    return box.containsKey('current_user_id');
  }

  // Ottieni ID utente corrente (locale o Firebase)
  static Future<String?> getCurrentUserId() async {
    if (_firebaseAvailable && currentUser != null) {
      return currentUser!.uid;
    }
    // Modalità locale
    final box = await LocalStorageService.getUserBox();
    return box.get('current_user_id') as String?;
  }

  // Registrazione nuovo utente (locale o Firebase)
  static Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    if (_firebaseAvailable && _auth != null) {
      // Registrazione Firebase
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      final profile = _createProfile(userId, name, age);

      await _firestore!.collection('users').doc(userId).set(profile.toMap());
      await userCredential.user!.updateDisplayName(name);

      return userCredential;
    } else {
      // Registrazione locale con Hive
      return await _signUpLocal(email, password, name, age);
    }
  }

  // Registrazione locale
  static Future<UserCredential?> _signUpLocal(
    String email,
    String password,
    String name,
    int age,
  ) async {
    final box = await LocalStorageService.getUserBox();
    
    // Controlla se email già esiste
    final users = box.toMap();
    for (var entry in users.entries) {
      if (entry.key.toString().startsWith('user_')) {
        final userData = entry.value as Map?;
        if (userData != null && userData['email'] == email) {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email già registrata',
          );
        }
      }
    }

    // Crea nuovo utente locale
    final userId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final profile = _createProfile(userId, name, age);

    // Salva credenziali
    await box.put('user_$userId', {
      'email': email,
      'password': password, // In produzione, usare hash!
      'profile': profile.toMap(),
    });

    // Imposta come utente corrente
    await box.put('current_user_id', userId);
    await box.put('current_user_profile', profile.toMap());

    if (kDebugMode) {
      debugPrint('✅ Local user registered: $email');
    }

    return null; // Ritorna null per utenti locali
  }

  // Login (locale o Firebase)
  static Future<UserCredential?> signIn(String email, String password) async {
    if (_firebaseAvailable && _auth != null) {
      // Login Firebase
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      // Login locale
      return await _signInLocal(email, password);
    }
  }

  // Login locale
  static Future<UserCredential?> _signInLocal(String email, String password) async {
    final box = await LocalStorageService.getUserBox();
    
    // Cerca utente per email
    final users = box.toMap();
    for (var entry in users.entries) {
      if (entry.key.toString().startsWith('user_')) {
        final userData = entry.value as Map?;
        if (userData != null && userData['email'] == email) {
          if (userData['password'] == password) {
            // Login successful
            final userId = entry.key.toString().replaceFirst('user_', '');
            await box.put('current_user_id', userId);
            await box.put('current_user_profile', userData['profile']);
            
            if (kDebugMode) {
              debugPrint('✅ Local user logged in: $email');
            }
            
            return null; // Ritorna null per utenti locali
          } else {
            throw FirebaseAuthException(
              code: 'wrong-password',
              message: 'Password errata',
            );
          }
        }
      }
    }

    throw FirebaseAuthException(
      code: 'user-not-found',
      message: 'Email non trovata',
    );
  }

  // Logout
  static Future<void> signOut() async {
    if (_firebaseAvailable && _auth != null) {
      await _auth!.signOut();
    }
    
    // Logout locale
    final box = await LocalStorageService.getUserBox();
    await box.delete('current_user_id');
    await box.delete('current_user_profile');
    
    if (kDebugMode) {
      debugPrint('✅ User logged out');
    }
  }

  // Carica profilo utente (locale o Firebase)
  static Future<UserProfile?> loadUserProfile(String userId) async {
    if (_firebaseAvailable && _firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(userId).get();
        if (!doc.exists) return null;
        return UserProfile.fromMap(doc.data()!);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error loading Firebase profile: $e');
        }
      }
    }
    
    // Carica profilo locale
    final box = await LocalStorageService.getUserBox();
    final profileData = box.get('current_user_profile') as Map?;
    
    if (profileData != null) {
      return UserProfile.fromMap(Map<String, dynamic>.from(profileData));
    }
    
    return null;
  }

  // Aggiorna profilo utente (locale o Firebase)
  static Future<void> updateUserProfile(UserProfile profile) async {
    if (_firebaseAvailable && _firestore != null) {
      await _firestore!.collection('users').doc(profile.id).update(profile.toMap());
    }
    
    // Aggiorna locale
    final box = await LocalStorageService.getUserBox();
    await box.put('current_user_profile', profile.toMap());
    
    // Aggiorna anche in user_<id>
    final userData = box.get('user_${profile.id}') as Map?;
    if (userData != null) {
      userData['profile'] = profile.toMap();
      await box.put('user_${profile.id}', userData);
    }
  }

  // Helper: crea profilo iniziale
  static UserProfile _createProfile(String userId, String name, int age) {
    return UserProfile(
      id: userId,
      name: name,
      age: age,
      startDate: DateTime.now(),
      language: 'it',
      theme: 'professional',
      textSize: 'normal',
      contrast: 'standard',
      sessionDuration: 15,
      weeklyFrequency: 5,
      remindersEnabled: true,
      currentLevel: 1,
      totalPoints: 0,
      sessionsCompleted: 0,
      streakDays: 0,
      cognitiveScores: {
        'memory': 50.0,
        'attention': 50.0,
        'executive': 50.0,
        'speed': 50.0,
        'language': 50.0,
        'spatial': 50.0,
      },
    );
  }
}
