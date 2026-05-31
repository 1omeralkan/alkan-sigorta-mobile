import '../../data/models/application_response.dart';

abstract class ApplicationState {}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationSuccess extends ApplicationState {}

class ApplicationFailure extends ApplicationState {
  final String message;

  ApplicationFailure(this.message);
}

class ApplicationListLoading extends ApplicationState {}

class ApplicationListLoaded extends ApplicationState {
  final List<ApplicationResponse> applications;

  ApplicationListLoaded(this.applications);
}

class ApplicationListFailure extends ApplicationState {
  final String message;

  ApplicationListFailure(this.message);
}
