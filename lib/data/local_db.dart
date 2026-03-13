import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checkin_record.dart';
import '../models/finish_class_record.dart';

class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();
  static const _checkinsKey = 'checkins_records';
  static const _finishClassKey = 'finish_class_records';

  Future<int> insertCheckin(CheckinRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_checkinsKey) ?? <String>[];
    final encoded = jsonEncode(record.toMap());
    final updated = [...existing, encoded];
    await prefs.setStringList(_checkinsKey, updated);
    return updated.length;
  }

  Future<int> insertFinishClass(FinishClassRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_finishClassKey) ?? <String>[];
    final encoded = jsonEncode(record.toMap());
    final updated = [...existing, encoded];
    await prefs.setStringList(_finishClassKey, updated);
    return updated.length;
  }

  Future<List<Map<String, dynamic>>> getCheckinHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final checkins = prefs.getStringList(_checkinsKey) ?? <String>[];

    final records = <Map<String, dynamic>>[];
    for (final entry in checkins) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        records.add({
          'type': 'Check-in',
          'timestamp': map['timestamp']?.toString() ?? '',
          'studentId': map['studentId']?.toString() ?? 'UNKNOWN',
          'studentName': map['studentName']?.toString() ?? 'Unknown Student',
        });
      } catch (_) {}
    }

    _sortByLatest(records);
    return records;
  }

  Future<List<Map<String, dynamic>>> getCheckoutHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final checkouts = prefs.getStringList(_finishClassKey) ?? <String>[];

    final records = <Map<String, dynamic>>[];
    for (final entry in checkouts) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        records.add({
          'type': 'Check-out',
          'timestamp': map['timestamp']?.toString() ?? '',
          'studentId': map['studentId']?.toString() ?? 'UNKNOWN',
          'studentName': map['studentName']?.toString() ?? 'Unknown Student',
        });
      } catch (_) {}
    }

    _sortByLatest(records);
    return records;
  }

  Future<List<Map<String, dynamic>>> getAttendanceTimeline() async {
    final prefs = await SharedPreferences.getInstance();
    final checkins = prefs.getStringList(_checkinsKey) ?? <String>[];
    final finishes = prefs.getStringList(_finishClassKey) ?? <String>[];

    final records = <Map<String, dynamic>>[];

    for (final entry in checkins) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        records.add({
          'type': 'Check-in',
          'timestamp': map['timestamp']?.toString() ?? '',
          'studentId': map['studentId']?.toString() ?? 'UNKNOWN',
          'studentName': map['studentName']?.toString() ?? 'Unknown Student',
        });
      } catch (_) {}
    }

    for (final entry in finishes) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        records.add({
          'type': 'Check-out',
          'timestamp': map['timestamp']?.toString() ?? '',
          'studentId': map['studentId']?.toString() ?? 'UNKNOWN',
          'studentName': map['studentName']?.toString() ?? 'Unknown Student',
        });
      } catch (_) {}
    }

    _sortByLatest(records);

    return records;
  }

  void _sortByLatest(List<Map<String, dynamic>> records) {
    records.sort((a, b) {
      final aTime = DateTime.tryParse(a['timestamp'] as String) ?? DateTime(1970);
      final bTime = DateTime.tryParse(b['timestamp'] as String) ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });
  }
}
