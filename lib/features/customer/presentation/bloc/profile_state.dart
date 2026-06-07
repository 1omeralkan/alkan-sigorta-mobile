import 'package:equatable/equatable.dart';
import '../../data/models/customer_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final CustomerModel customer;

  const ProfileLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class ProfileUpdating extends ProfileState {
  final CustomerModel customer;

  const ProfileUpdating(this.customer);

  @override
  List<Object?> get props => [customer];
}

class ProfileUpdateSuccess extends ProfileState {
  final CustomerModel customer;

  const ProfileUpdateSuccess(this.customer);

  @override
  List<Object?> get props => [customer];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
