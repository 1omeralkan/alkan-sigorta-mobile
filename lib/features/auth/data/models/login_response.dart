class LoginResponse {
  final String token;
  final int customerId;
  final String email;
  final String ad;
  final String soyad;

  LoginResponse({
    required this.token,
    required this.customerId,
    required this.email,
    required this.ad,
    required this.soyad,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      customerId: json['customerId'] as int,
      email: json['email'] as String,
      ad: json['ad'] as String,
      soyad: json['soyad'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'customerId': customerId,
      'email': email,
      'ad': ad,
      'soyad': soyad,
    };
  }
}
