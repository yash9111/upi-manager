class ImportResultModel {
  final int importedCount;

  final int skippedCount;

  final bool success;

  final String message;

  ImportResultModel({
    required this.importedCount,
    required this.skippedCount,
    required this.success,
    required this.message,
  });
}