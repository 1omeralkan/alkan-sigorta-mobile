import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/application_save_request.dart';
import '../../domain/repositories/application_repository.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepository _repository;

  ApplicationCubit(this._repository) : super(ApplicationInitial());

  Future<void> submitApplication(ApplicationSaveRequest request) async {
    emit(ApplicationLoading());

    try {
      await _repository.createApplication(request);
      emit(ApplicationSuccess());
    } catch (e) {
      emit(ApplicationFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
