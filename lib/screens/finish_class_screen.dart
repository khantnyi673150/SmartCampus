import 'package:flutter/material.dart';

import '../data/local_db.dart';
import '../models/finish_class_record.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  static const routeName = '/finish-class';

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  String? _qrValue;
  bool _isSaving = false;

  bool get _isFormReady {
    return _studentIdController.text.trim().isNotEmpty &&
        _studentNameController.text.trim().isNotEmpty &&
        _learnedTodayController.text.trim().isNotEmpty &&
        _feedbackController.text.trim().isNotEmpty &&
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
    _learnedTodayController.addListener(_onFormChanged);
    _feedbackController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _studentIdController.removeListener(_onFormChanged);
    _studentNameController.removeListener(_onFormChanged);
    _learnedTodayController.removeListener(_onFormChanged);
    _feedbackController.removeListener(_onFormChanged);
    _studentIdController.dispose();
    _studentNameController.dispose();
    _learnedTodayController.dispose();
    _feedbackController.dispose();
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
      final record = FinishClassRecord(
        studentId: _studentIdController.text.trim(),
        studentName: _studentNameController.text.trim(),
        timestamp: DateTime.now().toIso8601String(),
        latitude: position.latitude,
        longitude: position.longitude,
        qrValue: _qrValue!,
        learnedToday: _learnedTodayController.text.trim(),
        feedback: _feedbackController.text.trim(),
      );

      await LocalDb.instance.insertFinishClass(record);
      if (!mounted) return;
      _showSnackBar('Finish class data saved locally.');
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
        title: const Text('Finish Class'),
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
                        controller: _learnedTodayController,
                        decoration: const InputDecoration(
                          labelText: 'What did you learn today?',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter what you learned today';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _feedbackController,
                        decoration: const InputDecoration(
                          labelText: 'Feedback about class/instructor',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your feedback';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
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
                          child: Text(_isSaving ? 'Saving...' : 'Save Finish Class'),
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
