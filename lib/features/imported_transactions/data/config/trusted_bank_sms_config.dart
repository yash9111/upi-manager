import '../../domain/models/bank_sms_config.dart';

class TrustedBankSmsConfig {
  TrustedBankSmsConfig._();

  static const List<BankSmsConfig> banks = [
    BankSmsConfig(
      id: 'bank_1',
      name: 'Indian Bank',
      senderKeywords: ['INDIANBK', 'INDBNK'],
    ),

    BankSmsConfig(
      id: 'bank_2',
      name: 'Union Bank',
      senderKeywords: ['UNIONBK', 'UNIONBANK', 'UBI', 'UNIONB'],
    ),

    BankSmsConfig(
      id: 'bank_3',
      name: 'Axis Bank',
      senderKeywords: ['AXISBANK', 'AXISBK', 'AXISMR'],
    ),
  ];
}
