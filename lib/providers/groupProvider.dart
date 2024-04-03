import 'package:flutter/material.dart';
import 'package:trip_expense_tracker/models/group_expense.dart';

class GroupProvider extends ChangeNotifier {
  String groupName = "new";
  List<GroupExpense> _groupExpenses = [];

  void addGroupName(String name) {
    groupName = name;
    notifyListeners();
  }

  String getGroupName() {
    return groupName;
  }

  void addGroupExpense(GroupExpense groupExpense) {
    _groupExpenses.add(groupExpense);
    notifyListeners();
  }

  void addGroupExpenses(List<GroupExpense> groupExpenses) {
    _groupExpenses = groupExpenses;
    notifyListeners();
  }

  void deleteGroupExpense(final index) {
    _groupExpenses.removeAt(index);
    notifyListeners();
  }

  List<GroupExpense> getGroupExpense() {
    return _groupExpenses;
  }
}
