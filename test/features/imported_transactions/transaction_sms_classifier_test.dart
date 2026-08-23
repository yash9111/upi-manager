import 'package:flutter_test/flutter_test.dart';

import 'package:upi_tracker/features/imported_transactions/data/services/transaction_sms_classifier.dart';

void main() {
  const classifier =
      TransactionSmsClassifier();

  group('Debit SMS', () {
    test('Sent Rs transaction', () {
      const sms =
          'Sent Rs.60.00 from A/c *8383 on 22-08-26 '
          'to Shri Dev icecream.RRN 6583832290356.'
          'Avl Bal Rs.9262.05.Not you?SMS BLOCK to 9289592895-Indian Bank';

      expect(
        classifier.classify(sms),
        SmsTransactionClassification.debit,
      );
    });

    test('Another Sent Rs transaction', () {
      const sms =
          'Sent Rs.799.00 from A/c *8383 on 31-07-26 '
          'to SPOTIFY.RRN 127168334658.'
          'Avl Bal Rs.18870.47.Not you?';

      expect(
        classifier.classify(sms),
        SmsTransactionClassification.debit,
      );
    });

    test('Momo transaction', () {
      const sms =
          'Sent Rs.70.00 from A/c *8383 on 14-08-26 '
          'to The Lazy Momo.RRN 6583832290356.'
          'Avl Bal Rs.2105.89.';

      expect(
        classifier.classify(sms),
        SmsTransactionClassification.debit,
      );
    });
  });

  group('Credit SMS', () {
    test('Credited by person', () {
      const sms =
          'Your A/c *8383 is credited with Rs.1.00 '
          'on 22-08-26 by SHIVA PANDEYDO AVADH KISHOR SH. '
          'RRN 6583832290356. '
          'Available balance is Rs. 9322.05 - Indian Bank';

      expect(
        classifier.classify(sms),
        SmsTransactionClassification.credit,
      );
    });

    test('Credited by another person', () {
      const sms =
          'Your A/c *8383 is credited with Rs.96.60 '
          'on 11-08-26 by ANSHUL SAIN. '
          'RRN 6583832290356. '
          'Available balance is Rs. 9691.70';

      expect(
        classifier.classify(sms),
        SmsTransactionClassification.credit,
      );
    });

    test('Credited with larger amount', () {
      const sms =
          'Your A/c *8383 is credited with Rs.385.00 '
          'on 11-08-26 by ANSHIKA JAIN. '
          'RRN 614569797172. '
          'Available balance is Rs. 8848.28';

      expect(
        classifier.classify(sms),
        SmsTransactionClassification.credit,
      );
    });
  });

  group('Promotional SMS', () {
    test('BATA promotional SMS', () {
      const sms =
          'New Styles - Bigger Savings! Enjoy Friday Saver @ BATA. '
          'Get 250 OFF on purchases of Rs. 1000. '
          'Shop at nearest store or bit.ly/3Sg3W40 before 23 Aug. T&C';

      expect(
        classifier.classify(sms),
        SmsTransactionClassification.promotional,
      );
    });
  });
}