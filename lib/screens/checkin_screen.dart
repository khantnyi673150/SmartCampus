import 'package:flutter/material.dart';

import '../data/local_db.dart';
import '../models/checkin_record.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  static const routeName = '/check-in';

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  String? _qrValue;
  int _mood = 3;
  bool _isSaving = false;

  bool get _isFormReady {
    return _studentIdController.text.trim().isNotEmpty &&
        _studentNameController.text.trim().isNotEmpty &&
        _previousTopicController.text.trim().isNotEmpty &&
        _expectedTopicController.text.trim().isNotEmpty &&
        _qrValue != null;
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _studentIdController.addListener(_onFormChanged);
    _studentNameController.addListener(_onFormChanged);
    _previousTopicController.addListener(_onFormChanged);
    _expectedTopicController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _studentIdController.removeListener(_onFormChanged);
    _studentNameController.removeListener(_onFormChanged);
    _previousTopicController.removeListener(_onFormChanged);
    _expectedTopicController.removeListener(_onFormChanged);
    _studentIdController.dispose();
    _studentNameController.dispose();
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _qrValue = result);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_qrValue == null) {
      _showSnackBar('Please scan classroom QR code first.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final position = await LocationService.getCurrentPosition();
      final record = CheckinRecord(
        studentId: _studentIdController.text.trim(),
        studentName: _studentNameController.text.trim(),
        timestamp: DateTime.now().toIso8601String(),
        latitude: position.latitude,
        longitude: position.longitude,
        qrValue: _qrValue!,
        previousTopic: _previousTopicController.text.trim(),
        expectedTopic: _expectedTopicController.text.trim(),
        mood: _mood,
      );

      await LocalDb.instance.insertCheckin(record);
      if (!mounted) return;
      _showSnackBar('Check-in data saved locally.');
      Navigator.pop(context);
    } catch (error) {
      _showSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Check-in'),
        backgroundColor: const Color(0xFF2E6BFF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E6BFF), Color(0xFF7B1CFF)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'Student ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter student ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _studentNameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter student name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _previousTopicController,
                        decoration: const InputDecoration(
                          labelText: 'Previous class topic',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter previous class topic';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _expectedTopicController,
                        decoration: const InputDecoration(
                          labelText: 'Expected topic today',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter expected topic';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _scanQr,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _qrValue == null
                                ? const Color(0xFF2E6BFF)
                                : const Color(0xFF9CA3AF),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            _qrValue == null
                                ? 'Scan Classroom QR'
                                : 'QR Scanned',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_qrValue == null ? 'QR: Not scanned' : 'QR: $_qrValue'),
                      const SizedBox(height: 16),
                      Text('Mood before class: $_mood'),
                      Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        value: _mood.toDouble(),
                        label: _mood.toString(),
                        onChanged: (value) {
                          setState(() => _mood = value.toInt());
                        },
                      ),
                      const Text(
                        '1 = Very negative, 2 = Negative, 3 = Neutral, 4 = Positive, 5 = Very positive',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isSaving || !_isFormReady)
                              ? null
                              : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormReady
                                ? const Color(0xFF2E6BFF)
                                : const Color(0xFF9CA3AF),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_isSaving ? 'Saving...' : 'Save Check-in'),
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
}
