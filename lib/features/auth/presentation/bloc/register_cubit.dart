import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/customer_save_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/parameter_remote_data_source.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;
  final ParameterRemoteDataSource _parameterDataSource;

  RegisterCubit(
    this._authRepository,
    this._parameterDataSource,
  ) : super(const RegisterInitial()) {
    loadCountries();
  }

  Future<void> loadCountries() async {
    emit(RegisterInitial(
      countries: state.countries,
      cities: state.cities,
      isLoadingCountries: true,
      isLoadingCities: state.isLoadingCities,
    ));

    try {
      final countries = await _parameterDataSource.getCountries();
      emit(RegisterInitial(
        countries: countries,
        cities: state.cities,
        isLoadingCountries: false,
        isLoadingCities: state.isLoadingCities,
      ));
    } catch (e) {
      emit(RegisterFailure(
        'Ülke listesi yüklenemedi',
        countries: state.countries,
        cities: state.cities,
        isLoadingCountries: false,
        isLoadingCities: state.isLoadingCities,
      ));
    }
  }

  Future<void> loadCities(int countryId) async {
    emit(RegisterInitial(
      countries: state.countries,
      cities: [],
      isLoadingCountries: state.isLoadingCountries,
      isLoadingCities: true,
    ));

    try {
      final cities = await _parameterDataSource.getCities(countryId);
      emit(RegisterInitial(
        countries: state.countries,
        cities: cities,
        isLoadingCountries: state.isLoadingCountries,
        isLoadingCities: false,
      ));
    } catch (e) {
      emit(RegisterFailure(
        'Şehir listesi yüklenemedi',
        countries: state.countries,
        cities: [],
        isLoadingCountries: state.isLoadingCountries,
        isLoadingCities: false,
      ));
    }
  }

  void clearCities() {
    emit(RegisterInitial(
      countries: state.countries,
      cities: [],
      isLoadingCountries: state.isLoadingCountries,
      isLoadingCities: false,
    ));
  }

  Future<void> register(CustomerSaveRequest request) async {
    emit(RegisterLoading(
      countries: state.countries,
      cities: state.cities,
      isLoadingCountries: state.isLoadingCountries,
      isLoadingCities: state.isLoadingCities,
    ));

    try {
      await _authRepository.register(request);
      emit(RegisterSuccess(
        countries: state.countries,
        cities: state.cities,
        isLoadingCountries: state.isLoadingCountries,
        isLoadingCities: state.isLoadingCities,
      ));
    } catch (e) {
      emit(RegisterFailure(
        e.toString().replaceFirst('Exception: ', ''),
        countries: state.countries,
        cities: state.cities,
        isLoadingCountries: state.isLoadingCountries,
        isLoadingCities: state.isLoadingCities,
      ));
    }
  }
}
