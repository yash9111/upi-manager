import 'incoming_sms_service.dart';

class IncomingSmsBootstrapService {
  final IncomingSmsService incomingSmsService;

  const IncomingSmsBootstrapService({
    required this.incomingSmsService,
  });

  Future<IncomingSmsImportResult> process() {
    return incomingSmsService.processPendingSms();
  }
}