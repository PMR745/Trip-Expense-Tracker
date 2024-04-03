class SettleDown {
  String from;
  String to;
  double amount;
  bool done;

  SettleDown({
    required this.from,
    required this.to,
    required this.amount,
    required this.done,
  });

  factory SettleDown.fromMap(Map<String, dynamic> json) {
    return SettleDown(
      from: json['from'],
      to: json['to'],
      amount: json['amount'],
      done: json['done'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "from": from,
      "to": to,
      "amount": amount,
      "done": done,
    };
  }
}
