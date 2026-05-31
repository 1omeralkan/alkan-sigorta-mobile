class PaymentRequest {
  final String cardNumber;
  final String cardHolderName;
  final String expireMonth;
  final String expireYear;
  final String cvv;
  final double amount;

  PaymentRequest({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expireMonth,
    required this.expireYear,
    required this.cvv,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expireMonth': expireMonth,
      'expireYear': expireYear,
      'cvv': cvv,
      'amount': amount,
    };
  }
}
