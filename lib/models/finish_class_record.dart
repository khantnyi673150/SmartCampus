class FinishClassRecord {
  const FinishClassRecord({
    required this.studentId,
    required this.studentName,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.qrValue,
    required this.learnedToday,
    required this.feedback,
  });

  final String studentId;
  final String studentName;
  final String timestamp;
  final double latitude;
  final double longitude;
  final String qrValue;
  final String learnedToday;
  final String feedback;

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'qrValue': qrValue,
      'learnedToday': learnedToday,
      'feedback': feedback,
    };
  }
}
