enum PaymentType { cardPayment, mpmQrPayment, cpmQrPayment }

extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.cardPayment:
        return 'Card Payment';
      case PaymentType.mpmQrPayment:
        return 'MPM QR Payment';
      case PaymentType.cpmQrPayment:
        return 'CPM QR Payment';
    }
  }
}
