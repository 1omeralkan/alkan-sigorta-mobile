class CustomerUpdateRequest {
  final String ad;
  final String soyad;
  final String email;
  final String tcNo;
  final String password;
  final int? addressCountryId;
  final int? addressCityId;
  final String? openAddress;
  final int? phoneCountryId;
  final String? phoneNumber;

  CustomerUpdateRequest({
    required this.ad,
    required this.soyad,
    required this.email,
    required this.tcNo,
    required this.password,
    this.addressCountryId,
    this.addressCityId,
    this.openAddress,
    this.phoneCountryId,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'ad': ad,
      'soyad': soyad,
      'email': email,
      'tcNo': tcNo,
      'password': password,
      'addressCountryId': addressCountryId,
      'addressCityId': addressCityId,
      'openAddress': openAddress,
      'phoneCountryId': phoneCountryId,
      'phoneNumber': phoneNumber,
    };
  }
}
