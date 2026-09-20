import 'models/verification_models.dart';

abstract class VerificationGateway {
  Future<UnifiedVerificationResult> verify(VerificationRequest request);
}
