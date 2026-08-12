/// Gaza governorates offered for delivery, each with its delivery fee (₪).
enum Governorate {
  northGaza('شمال غزة', 15),
  gazaCity('مدينة غزة', 10),
  middleArea('المحافظة الوسطى', 15),
  khanYounis('خان يونس', 20),
  rafah('رفح', 25);

  const Governorate(this.labelAr, this.deliveryFee);

  final String labelAr;
  final double deliveryFee;
}

/// Supported payment methods. Cash on delivery is the default and only fully
/// active method; the e-wallets are integration slots ("coming soon").
enum PaymentMethod {
  cashOnDelivery('الدفع عند الاستلام', 'الدفع نقداً عند استلام الطلب', true),
  jawwalPay('Jawwal Pay', 'محفظة جوال الإلكترونية', false),
  maqbool('Maqbool', 'محفظة مقبول الإلكترونية', false);

  const PaymentMethod(this.labelAr, this.subtitleAr, this.available);

  final String labelAr;
  final String subtitleAr;

  /// Whether the method is live. `false` renders as a disabled "قريباً" slot.
  final bool available;
}

/// Lifecycle status of a placed order.
enum OrderStatus {
  pending('قيد المعالجة'),
  confirmed('تم التأكيد'),
  onTheWay('في الطريق'),
  delivered('تم التوصيل'),
  cancelled('ملغي');

  const OrderStatus(this.labelAr);

  final String labelAr;
}
