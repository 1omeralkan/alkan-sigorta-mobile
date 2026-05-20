abstract class ApplicationState {}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationSuccess extends ApplicationState {}

class ApplicationFailure extends ApplicationState {
  final String message;

  ApplicationFailure(this.message);
}
