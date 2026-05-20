class CountryModel {
  final int id;
  final String name;
  final String? phoneCode;

  CountryModel({
    required this.id,
    required this.name,
    this.phoneCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phoneCode: json['phoneCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (phoneCode != null) 'phoneCode': phoneCode,
    };
  }
}
