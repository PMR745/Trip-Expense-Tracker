import 'package:mongo_dart/mongo_dart.dart';
import 'package:trip_expense_tracker/models/group_expense.dart';
import 'package:trip_expense_tracker/models/group_participants.dart';

class GroupModel {
  ObjectId id;
  String groupName;
  String groupPassword;
  List<GroupParticipants> groupParticipants;
  List<GroupExpense> groupExpenses;

  GroupModel({
    required this.id,
    required this.groupName,
    required this.groupPassword,
    required this.groupParticipants,
    required this.groupExpenses,
  });

  factory GroupModel.fromMap(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      groupName: json['groupName'],
      groupPassword: json['groupExpense'],
      groupParticipants: json['groupParticipants'],
      groupExpenses: json['groupExpenses'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "groupName": groupName,
      "groupPassword": groupPassword,
      "groupParticipants":
          groupParticipants.map((participant) => participant.toJson()).toList(),
      "groupExpenses":
          groupExpenses.map((expense) => expense.toJson()).toList(),
    };
  }
}
