class Worker {
  final String workName;
  final String name;
  final double rate;
  final double discount;
  final double payment;

  Worker({
    required this.workName,
    required this.name,
    required this.rate,
    required this.discount,
    required this.payment,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      workName: json['workName'] as String,
      name: json['name'] as String,
      rate: json['rate'] as double,
      discount: json['discount'] as double,
      payment: json['payment'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workName': workName,
      'name': name,
      'rate': rate,
      'discount': discount,
      'payment': payment,
    };
  }
}
