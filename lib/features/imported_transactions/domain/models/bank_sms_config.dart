class BankSmsConfig {
  final String id;
  final String name;
  final List<String> senderKeywords;

  const BankSmsConfig({
    required this.id,
    required this.name,
    required this.senderKeywords,
  });
}