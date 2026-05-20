import '../../data/models/application_save_request.dart';

abstract class ApplicationRepository {
  Future<void> createApplication(ApplicationSaveRequest request);
}
