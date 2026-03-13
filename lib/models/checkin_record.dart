class CheckinRecord {
  const CheckinRecord({
    required this.studentId,
    required this.studentName,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.qrValue,
    required this.previousTopic,
    required this.expectedTopic,
    required this.mood,
  });

  final String studentId;
  final String studentName;
  final String timestamp;
  final double latitude;
  final double longitude;
  final String qrValue;
  final String previousTopic;
  final String expectedTopic;
  final int mood;

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'qrValue': qrValue,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'mood': mood,
    };
  }
}
