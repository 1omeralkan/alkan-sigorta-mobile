class CustomerSaveRequest {
  final String ad;
  final String soyad;
  final String tcNo;
  final String email;
  final String password;
  final DateTime dogumTarihi;
  final String? dogumYeri;
  final int? addressCountryId;
  final int? addressCityId;
  final String? openAddress;
  final int? phoneCountryId;
  final String phoneNumber;

  CustomerSaveRequest({
    required this.ad,
    required this.soyad,
    required this.tcNo,
    required this.email,
    required this.password,
    required this.dogumTarihi,
    this.dogumYeri,
    this.addressCountryId,
    this.addressCityId,
    this.openAddress,
    this.phoneCountryId,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'ad': ad,
      'soyad': soyad,
      'tcNo': tcNo,
      'email': email,
      'password': password,
      'dogumTarihi': dogumTarihi.toIso8601String(),
      if (dogumYeri != null) 'dogumYeri': dogumYeri,
      if (addressCountryId != null) 'addressCountryId': addressCountryId,
      if (addressCityId != null) 'addressCityId': addressCityId,
      if (openAddress != null) 'openAddress': openAddress,
      if (phoneCountryId != null) 'phoneCountryId': phoneCountryId,
      'phoneNumber': phoneNumber,
    };
  }
}
