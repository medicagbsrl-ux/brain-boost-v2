import 'package:flutter/material.dart';
import '../services/firebase_sync_service.dart';
import '../services/local_storage_service.dart';

class FirebaseMigrationScreen extends StatefulWidget {
  final String userId;

  const FirebaseMigrationScreen({
    super.key,
    required this.userId,
  });

  @override
  State<FirebaseMigrationScreen> createState() => _FirebaseMigrationScreenState();
}

class _FirebaseMigrationScreenState extends State<FirebaseMigrationScreen> {
  bool _isMigrating = false;
  bool _migrationCompleted = false;
  String _statusMessage = 'Pronto per la migrazione';
  int _migratedSessions = 0;
  
  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
      _statusMessage = '🔄 Avvio migrazione...';
    });
    
    try {
      // Step 1: Migra profilo utente
      setState(() {
        _statusMessage = '📋 Migrazione profilo utente...';
      });
      await Future.delayed(const Duration(milliseconds: 500));
      
      final profile = await LocalStorageService.getUserProfile();
      if (profile != null && profile.id == widget.userId) {
        await FirebaseSyncService.syncUserProfile(profile);
      }
      
      // Step 2: Migra sessioni
      setState(() {
        _statusMessage = '🎮 Migrazione sessioni di gioco...';
      });
      
      final sessions = await LocalStorageService.getAllSessionHistory(widget.userId);
      _migratedSessions = sessions.length;
      
      for (int i = 0; i < sessions.length; i++) {
        await FirebaseSyncService.syncSessionHistory(sessions[i]);
        
        // Update progress
        if ((i + 1) % 10 == 0 || i == sessions.length - 1) {
          setState(() {
            _statusMessage = '🎮 Migrate ${i + 1}/${sessions.length} sessioni...';
          });
        }
      }
      
      // Completed
      setState(() {
        _isMigrating = false;
        _migrationCompleted = true;
        _statusMessage = '✅ Migrazione completata!';
      });
      
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _statusMessage = '❌ Errore: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migrazione Database'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.cloud_upload,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Migrazione Cloud Firebase',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Questa operazione caricherà tutti i tuoi dati locali su Firebase Cloud. '
                'I tuoi dati saranno sincronizzati automaticamente su tutti i tuoi dispositivi.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              
              const SizedBox(height: 32),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _migrationCompleted 
                                ? Icons.check_circle 
                                : _isMigrating 
                                    ? Icons.sync 
                                    : Icons.info_outline,
                            color: _migrationCompleted 
                                ? Colors.green 
                                : _isMigrating 
                                    ? Colors.blue 
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (_isMigrating) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                      
                      if (_migrationCompleted) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Sessioni migrate: $_migratedSessions',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              if (!_migrationCompleted && !_isMigrating)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startMigration,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Avvia Migrazione'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              
              if (_migrationCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Fatto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              const Text(
                '💡 Suggerimento: I tuoi dati locali rimarranno intatti. '
                'Da ora in poi, ogni modifica sarà automaticamente sincronizzata con il cloud.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
