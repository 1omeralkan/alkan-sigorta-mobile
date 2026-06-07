class CustomerModel {
  final int id;
  final String ad;
  final String soyad;
  final String email;
  final String tcNo;
  final int? addressCountryId;
  final String? addressCountryName;
  final int? addressCityId;
  final String? addressCityName;
  final String? openAddress;
  final int? phoneCountryId;
  final String? phoneCode;
  final String? phoneNumber;

  CustomerModel({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.tcNo,
    this.addressCountryId,
    this.addressCountryName,
    this.addressCityId,
    this.addressCityName,
    this.openAddress,
    this.phoneCountryId,
    this.phoneCode,
    this.phoneNumber,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      ad: json['ad'] ?? '',
      soyad: json['soyad'] ?? '',
      email: json['email'] ?? '',
      tcNo: json['tcNo'] ?? '',
      addressCountryId: json['addressCountryId'],
      addressCountryName: json['addressCountryName'],
      addressCityId: json['addressCityId'],
      addressCityName: json['addressCityName'],
      openAddress: json['openAddress'],
      phoneCountryId: json['phoneCountryId'],
      phoneCode: json['phoneCode'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'soyad': soyad,
      'email': email,
      'tcNo': tcNo,
      'addressCountryId': addressCountryId,
      'addressCityId': addressCityId,
      'openAddress': openAddress,
      'phoneCountryId': phoneCountryId,
      'phoneNumber': phoneNumber,
    };
  }

  String get fullName => '$ad $soyad';
  String get fullPhone => phoneCode != null && phoneNumber != null
      ? '+$phoneCode $phoneNumber'
      : phoneNumber ?? 'Belirtilmemiş';
}
