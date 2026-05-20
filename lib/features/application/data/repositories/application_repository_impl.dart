import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_data_source.dart';
import '../models/application_save_request.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource _remoteDataSource;

  ApplicationRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createApplication(ApplicationSaveRequest request) async {
    try {
      await _remoteDataSource.createApplication(request);
    } catch (e) {
      rethrow;
    }
  }
}
