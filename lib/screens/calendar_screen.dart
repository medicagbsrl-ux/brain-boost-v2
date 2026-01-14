import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scheduled_session.dart';
import '../services/local_storage_service.dart';
import '../providers/user_profile_provider.dart';

/// Schermata Calendario Sessioni con Reminder
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  List<ScheduledSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    
    final profile = Provider.of<UserProfileProvider>(context, listen: false);
    final sessions = await LocalStorageService.getScheduledSessions(profile.currentProfile!.id);
    
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Riabilitazione'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSessionDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendarHeader(),
                _buildWeekdayHeaders(),
                Expanded(child: _buildCalendarGrid()),
                _buildSessionsList(),
              ],
            ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
            },
          ),
          Text(
            _getMonthYearText(_selectedDate),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    
    // Calcola giorno inizio settimana (lunedì = 1)
    int startWeekday = firstDay.weekday;
    
    // Giorni del mese precedente da mostrare
    final previousMonthDays = startWeekday - 1;
    
    final days = <Widget>[];
    
    // Giorni mese precedente (grigi)
    if (previousMonthDays > 0) {
      final prevMonthLastDay = DateTime(firstDay.year, firstDay.month, 0).day;
      for (int i = previousMonthDays; i > 0; i--) {
        days.add(_buildDayCell(
          prevMonthLastDay - i + 1,
          isCurrentMonth: false,
        ));
      }
    }
    
    // Giorni mese corrente
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(_buildDayCell(i, isCurrentMonth: true));
    }
    
    // Giorni mese successivo (grigi) per completare griglia
    final remainingCells = 42 - days.length; // 6 settimane * 7 giorni
    for (int i = 1; i <= remainingCells; i++) {
      days.add(_buildDayCell(i, isCurrentMonth: false));
    }
    
    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.all(8),
      children: days,
    );
  }

  Widget _buildDayCell(int day, {required bool isCurrentMonth}) {
    final date = DateTime(_selectedDate.year, _selectedDate.month, day);
    final isToday = _isSameDay(date, DateTime.now());
    final hasSession = _hasSessionOnDate(date);
    final isSelected = _isSameDay(date, _selectedDate);
    
    return GestureDetector(
      onTap: isCurrentMonth ? () {
        setState(() {
          _selectedDate = date;
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : null,
          borderRadius: BorderRadius.circular(8),
          border: hasSession
              ? Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : !isCurrentMonth
                          ? Colors.grey[400]
                          : null,
                  fontWeight: isToday ? FontWeight.bold : null,
                ),
              ),
            ),
            if (hasSession)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    final sessionsOnDate = _getSessionsForDate(_selectedDate);
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sessioni ${_formatDate(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sessionsOnDate.isNotEmpty)
                  Text(
                    '${sessionsOnDate.length} sessioni',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Expanded(
            child: sessionsOnDate.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Nessuna sessione programmata',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sessionsOnDate.length,
                    itemBuilder: (context, index) {
                      final session = sessionsOnDate[index];
                      return _buildSessionCard(session);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ScheduledSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: session.completed
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
          child: Icon(
            session.completed ? Icons.check : Icons.fitness_center,
            color: Colors.white,
          ),
        ),
        title: Text(
          _getGameName(session.plannedGames.first),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${session.scheduledTime.hour.toString().padLeft(2, '0')}:${session.scheduledTime.minute.toString().padLeft(2, '0')} • ${session.durationMinutes} min',
        ),
        trailing: session.completed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteSession(session),
              ),
        onTap: session.completed ? null : () => _startSession(session),
      ),
    );
  }

  void _showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSessionDialog(
        selectedDate: _selectedDate,
        onSessionAdded: () {
          _loadSessions();
        },
      ),
    );
  }

  void _deleteSession(ScheduledSession session) async {
    await LocalStorageService.deleteScheduledSession(session.id);
    _loadSessions();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessione eliminata')),
      );
    }
  }

  void _startSession(ScheduledSession session) {
    // TODO: Avvia gioco specifico
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Avvio ${_getGameName(session.plannedGames.first)}...')),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasSessionOnDate(DateTime date) {
    return _sessions.any((session) => _isSameDay(session.scheduledTime, date));
  }

  List<ScheduledSession> _getSessionsForDate(DateTime date) {
    return _sessions
        .where((session) => _isSameDay(session.scheduledTime, date))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getGameName(String gameId) {
    const gameNames = {
      'memory_match': 'Memory Match',
      'stroop_test': 'Test di Stroop',
      'reaction_time': 'Tempo di Reazione',
      'number_sequence': 'Sequenze Numeriche',
      'pattern_recognition': 'Riconoscimento Pattern',
      'word_association': 'Associazione Parole',
      'spatial_memory': 'Memoria Spaziale',
    };
    return gameNames[gameId] ?? gameId;
  }
}

/// Dialog per aggiungere nuova sessione
class AddSessionDialog extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onSessionAdded;

  const AddSessionDialog({
    super.key,
    required this.selectedDate,
    required this.onSessionAdded,
  });

  @override
  State<AddSessionDialog> createState() => _AddSessionDialogState();
}

class _AddSessionDialogState extends State<AddSessionDialog> {
  String _selectedGame = 'memory_match';
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duration = 15;
  bool _setReminder = true;
  final bool _reminderSent = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Programma Sessione'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selezione gioco
            const Text('Gioco:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedGame,
              items: const [
                DropdownMenuItem(value: 'memory_match', child: Text('Memory Match')),
                DropdownMenuItem(value: 'stroop_test', child: Text('Test di Stroop')),
                DropdownMenuItem(value: 'reaction_time', child: Text('Tempo di Reazione')),
                DropdownMenuItem(value: 'number_sequence', child: Text('Sequenze Numeriche')),
                DropdownMenuItem(value: 'pattern_recognition', child: Text('Riconoscimento Pattern')),
                DropdownMenuItem(value: 'word_association', child: Text('Associazione Parole')),
                DropdownMenuItem(value: 'spatial_memory', child: Text('Memoria Spaziale')),
              ],
              onChanged: (value) => setState(() => _selectedGame = value!),
            ),
            
            const SizedBox(height: 16),
            
            // Selezione orario
            const Text('Orario:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Durata
            const Text('Durata (minuti):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [10, 15, 20, 30].map((min) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$min'),
                      selected: _duration == min,
                      onSelected: (_) => setState(() => _duration = min),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Reminder
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Imposta Reminder'),
              subtitle: const Text('Riceverai una notifica'),
              value: _setReminder,
              onChanged: (value) => setState(() => _setReminder = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () async {
            final profile = Provider.of<UserProfileProvider>(context, listen: false);
            
            final session = ScheduledSession(
              id: 'session_${DateTime.now().millisecondsSinceEpoch}',
              userId: profile.currentProfile!.id,
              durationMinutes: _duration,
              plannedGames: [_selectedGame],
              scheduledTime: DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month,
                widget.selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              ),
              completed: false,
              reminderSent: _reminderSent,
            );
            
            await LocalStorageService.saveScheduledSession(session);
            
            if (context.mounted) {
              Navigator.pop(context);
              widget.onSessionAdded();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sessione programmata!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
