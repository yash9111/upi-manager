class SmsMessageData {
  final String body;
  final DateTime date;
  final String? address;

  const SmsMessageData({
    required this.body,
    required this.date,
    this.address,
  });
}

abstract class SmsReaderService {
  Future<List<SmsMessageData>> getMessages({
    required DateTime startDate,
    required DateTime endDate,
  });
}