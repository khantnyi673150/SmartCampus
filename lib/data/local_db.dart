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
    final checkouts = prefs.getStringList(_finishClassKey) ?? <String>[];
    final checkoutKeys = _buildAttendanceKeys(checkouts);

    final records = <Map<String, dynamic>>[];
    for (final entry in checkins) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        final studentId = map['studentId']?.toString() ?? 'UNKNOWN';
        final timestamp = map['timestamp']?.toString() ?? '';
        final attendanceKey = _attendanceKey(studentId, timestamp);
        final isFinished = checkoutKeys.contains(attendanceKey);

        records.add({
          'type': 'Check-in',
          'timestamp': timestamp,
          'studentId': studentId,
          'studentName': map['studentName']?.toString() ?? 'Unknown Student',
          'latitude': _toDouble(map['latitude']),
          'longitude': _toDouble(map['longitude']),
          'attendance': isFinished ? 'Finished' : 'Not finished',
        });
      } catch (_) {}
    }

    _sortByLatest(records);
    return records;
  }

  Future<List<Map<String, dynamic>>> getCheckoutHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final checkouts = prefs.getStringList(_finishClassKey) ?? <String>[];
    final checkins = prefs.getStringList(_checkinsKey) ?? <String>[];
    final checkinKeys = _buildAttendanceKeys(checkins);

    final records = <Map<String, dynamic>>[];
    for (final entry in checkouts) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        final studentId = map['studentId']?.toString() ?? 'UNKNOWN';
        final timestamp = map['timestamp']?.toString() ?? '';
        final attendanceKey = _attendanceKey(studentId, timestamp);
        final isFinished = checkinKeys.contains(attendanceKey);

        records.add({
          'type': 'Check-out',
          'timestamp': timestamp,
          'studentId': studentId,
          'studentName': map['studentName']?.toString() ?? 'Unknown Student',
          'latitude': _toDouble(map['latitude']),
          'longitude': _toDouble(map['longitude']),
          'attendance': isFinished ? 'Finished' : 'Not finished',
        });
      } catch (_) {}
    }

    _sortByLatest(records);
    return records;
  }

  Future<List<Map<String, dynamic>>> getAttendanceSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final checkins = prefs.getStringList(_checkinsKey) ?? <String>[];
    final checkouts = prefs.getStringList(_finishClassKey) ?? <String>[];
    final checkoutKeys = _buildAttendanceKeys(checkouts);

    final sheet = <Map<String, dynamic>>[];
    for (final entry in checkins) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        final studentId = map['studentId']?.toString() ?? 'UNKNOWN';
        final timestamp = map['timestamp']?.toString() ?? '';
        final attendanceKey = _attendanceKey(studentId, timestamp);
        final isFinished = checkoutKeys.contains(attendanceKey);

        sheet.add({
          'studentId': studentId,
          'studentName': map['studentName']?.toString() ?? 'Unknown Student',
          'timestamp': timestamp,
          'attendance': isFinished ? 'Finished' : 'Not finished',
        });
      } catch (_) {}
    }

    _sortByLatest(sheet);
    return sheet;
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

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Set<String> _buildAttendanceKeys(List<String> records) {
    final keys = <String>{};
    for (final entry in records) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(entry));
        final studentId = map['studentId']?.toString() ?? 'UNKNOWN';
        final timestamp = map['timestamp']?.toString() ?? '';
        keys.add(_attendanceKey(studentId, timestamp));
      } catch (_) {}
    }
    return keys;
  }

  String _attendanceKey(String studentId, String timestamp) {
    final date = DateTime.tryParse(timestamp);
    final day = date == null
        ? 'unknown-date'
        : '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${studentId.toLowerCase()}|$day';
  }
}
