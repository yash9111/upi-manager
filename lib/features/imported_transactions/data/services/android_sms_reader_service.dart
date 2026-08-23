import 'package:flutter_sms_reader/flutter_sms_reader.dart';

import 'sms_reader_service.dart';

class AndroidSmsReaderService
    implements SmsReaderService {
  @override
  Future<List<SmsMessageData>> getMessages({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final messages =
        await FlutterSmsReader.getAllSms();

    final result =
        <SmsMessageData>[];

    for (final message in messages) {
      final date = message.date;

      if (date.isBefore(startDate) ||
          date.isAfter(endDate)) {
        continue;
      }

      final body = message.body;

      if (body.trim().isEmpty) {
        continue;
      }

      result.add(
        SmsMessageData(
          body: body,
          date: date,
          address: message.address,
        ),
      );
    }

    result.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return result;
  }
}