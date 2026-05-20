import '../../data/models/country_model.dart';
import '../../data/models/city_model.dart';

abstract class RegisterState {
  final List<CountryModel> countries;
  final List<CityModel> cities;
  final bool isLoadingCountries;
  final bool isLoadingCities;

  const RegisterState({
    this.countries = const [],
    this.cities = const [],
    this.isLoadingCountries = false,
    this.isLoadingCities = false,
  });
}

class RegisterInitial extends RegisterState {
  const RegisterInitial({
    super.countries,
    super.cities,
    super.isLoadingCountries,
    super.isLoadingCities,
  });
}

class RegisterLoading extends RegisterState {
  const RegisterLoading({
    super.countries,
    super.cities,
    super.isLoadingCountries,
    super.isLoadingCities,
  });
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess({
    super.countries,
    super.cities,
    super.isLoadingCountries,
    super.isLoadingCities,
  });
}

class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure(
    this.message, {
    super.countries,
    super.cities,
    super.isLoadingCountries,
    super.isLoadingCities,
  });
}
