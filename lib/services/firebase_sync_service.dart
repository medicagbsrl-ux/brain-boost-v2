import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/session_history.dart';
import 'local_storage_service.dart';

/// Firebase Firestore Sync Service
/// Syncs local Hive data with Firebase Cloud
class FirebaseSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Sync user profile to Firebase
  static Future<void> syncUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('❌ Error syncing user profile: $e');
      rethrow;
    }
  }
  
  /// Sync session history to Firebase
  static Future<void> syncSessionHistory(SessionHistory session) async {
    try {
      await _firestore
          .collection('sessions')
          .doc(session.id)
          .set(session.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('❌ Error syncing session: $e');
      rethrow;
    }
  }
  
  /// Load user profile from Firebase
  static Future<UserProfile?> loadUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (!doc.exists) return null;
      
      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      print('❌ Error loading user profile: $e');
      return null;
    }
  }
  
  /// Load all sessions for a user from Firebase
  static Future<List<SessionHistory>> loadUserSessions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => SessionHistory.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error loading sessions: $e');
      return [];
    }
  }
  
  /// Initial migration: Upload all local Hive data to Firebase
  static Future<void> migrateLocalToFirebase(String userId) async {
    try {
      print('🔄 Starting migration from Hive to Firebase...');
      
      // 1. Migrate user profile
      final profile = await LocalStorageService.getUserProfile();
      if (profile != null && profile.id == userId) {
        await syncUserProfile(profile);
        print('✅ User profile migrated');
      }
      
      // 2. Migrate all sessions
      final sessions = await LocalStorageService.getAllSessionHistory(userId);
      int count = 0;
      for (final session in sessions) {
        await syncSessionHistory(session);
        count++;
      }
      print('✅ Migrated $count sessions');
      
      print('✅ Migration completed successfully!');
    } catch (e) {
      print('❌ Migration error: $e');
      rethrow;
    }
  }
  
  /// Listen to real-time updates for user profile
  static Stream<UserProfile?> watchUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return UserProfile.fromJson(snapshot.data()!);
        });
  }
  
  /// Delete user data from Firebase (for GDPR compliance)
  static Future<void> deleteUserData(String userId) async {
    try {
      // Delete user profile
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete all sessions
      final sessions = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in sessions.docs) {
        await doc.reference.delete();
      }
      
      print('✅ User data deleted from Firebase');
    } catch (e) {
      print('❌ Error deleting user data: $e');
      rethrow;
    }
  }
}
