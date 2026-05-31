import '../../data/models/application_save_request.dart';
import '../../data/models/application_response.dart';

abstract class ApplicationRepository {
  Future<void> createApplication(ApplicationSaveRequest request);
  Future<List<ApplicationResponse>> getApplicationsByCustomerId(int customerId);
  Future<void> cancelApplication(int applicationId);
}
