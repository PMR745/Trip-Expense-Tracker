class GroupExpense {
  String expenseName;
  String expenseAmount;
  String expenseDoneBy;
  DateTime timeOfExpense;

  GroupExpense({
    required this.expenseName,
    required this.expenseAmount,
    required this.expenseDoneBy,
    required this.timeOfExpense,
  });

  factory GroupExpense.fromMap(Map<String, dynamic> json) {
    return GroupExpense(
      expenseName: json['expenseName'],
      expenseAmount: json['expenseAmount'],
      expenseDoneBy: json['expenseDoneBy'],
      timeOfExpense: json['timeOfExpense'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "expenseName": expenseName,
      "expenseAmount": expenseAmount,
      "expenseDoneBy": expenseDoneBy,
      "timeOfExpense": timeOfExpense,
    };
  }
}
