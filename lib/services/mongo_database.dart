import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:trip_expense_tracker/models/group.dart';
import 'package:trip_expense_tracker/models/group_expense.dart';
import 'package:trip_expense_tracker/models/group_participants.dart';
import 'package:trip_expense_tracker/models/settle_down.dart';
import 'package:trip_expense_tracker/services/constants.dart';

class MongoDatabase {
  static var db, userCollection;
  static connect() async {
    db = await Db.create(MONGO_CONNECTION_URL);
    await db.open(secure: true);
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }

  // Creation of Group in MongoDB
  static createGroup(GroupModel group) async {
    try {
      var jsonFormat = group.toJson();
      await userCollection.insertOne(jsonFormat);
    } catch (e) {
      print(e.toString());
    }
  }

  // Check if group already exists
  static getGroup(String groupName) async {
    var result = await userCollection.findOne({"groupName": groupName});
    return result;
  }

  // Joining the group
  static Future<bool> joinGroup(String groupName, String password) async {
    var group = await userCollection.findOne({"groupName": groupName});
    if (password == group['groupPassword'] && group != null) {
      return true;
    }
    return false;
  }

  // Adding Group Participants
  static addParticipants(String groupName, String participantName) async {
    var group = await userCollection.findOne({"groupName": groupName});
    List participants = group['groupParticipants'];
    GroupParticipants groupParticipant = GroupParticipants(
        participantName: participantName, amountExpended: 0.0);
    participants.add(groupParticipant.toJson());
    group['groupParticipants'] = participants;
    await userCollection.update(where.eq('groupName', groupName), {
      r'$set': {'groupParticipants': participants}
    });
  }

  // Setting group expense
  static addGroupExpense(String groupName, GroupExpense groupExpense) async {
    var group = await userCollection.findOne({"groupName": groupName});
    List groupParticipants = group['groupParticipants'];
    groupParticipants.forEach((element) {
      if (groupExpense.expenseDoneBy == element['participantName']) {
        element['amountExpended'] += double.parse(groupExpense.expenseAmount);
      }
    });
    List<dynamic> expenses = group['groupExpenses'];
    expenses.add(groupExpense.toJson());
    await userCollection.update(where.eq('groupName', groupName), {
      r'$set': {
        'groupExpenses': expenses,
        'groupParticipants': groupParticipants
      }
    });
  }

  // Getting participants name
  static Future<List<String>> getParticipantsName(String groupName) async {
    var group = await userCollection.findOne({"groupName": groupName});
    List<String> participantsName = [];
    group['groupParticipants'].forEach((participant) {
      participantsName.add(participant['participantName']);
    });
    return participantsName;
  }

  static Future<List<GroupParticipants>> getGroupParticipants(
      String groupName) async {
    var group = await userCollection.findOne({"groupName": groupName});
    final result = group['groupParticipants'] as List<dynamic>;
    final groupParticipants = result.map((e) {
      return GroupParticipants.fromMap(e);
    }).toList();
    return groupParticipants;
  }

  static Future<List<GroupExpense>> getGroupExpenses(String groupName) async {
    var group = await userCollection.findOne({"groupName": groupName});
    final result = group['groupExpenses'] as List<dynamic>;
    final groupExpense = result.map((e) {
      return GroupExpense.fromMap(e);
    }).toList();
    return groupExpense;
  }

  // Add settle down
  static Future addSettleDown(
      String groupName, List<SettleDown> settleDown) async {
    await userCollection.update(where.eq('groupName', groupName), {
      r'$set': {
        'groupSettleDowns': settleDown.map((e) => e.toJson()).toList(),
      }
    });
  }

  // Get Settle down
  static Future<List<SettleDown>> getSettleDown(String groupName) async {
    var group = await userCollection.findOne({"groupName": groupName});
    var result = group['groupSettleDowns'] as List<dynamic>;
    var transfomed = result.map((e) => SettleDown.fromMap(e)).toList();
    return transfomed;
  }

  // Deleting a group expense
  static Future deleteGroupExpense(
      String groupName, int index, GroupExpense expense) async {
    var group = await userCollection.findOne({"groupName": groupName});
    final expenses = await group['groupExpenses'];
    expenses.removeAt(index);
    final participants = await group['groupParticipants'];
    participants.forEach((participant) {
      if (participant['participantName'] == expense.expenseDoneBy) {
        participant['amountExpended'] -= double.parse(expense.expenseAmount);
      }
    });

    await userCollection.update(where.eq('groupName', groupName), {
      r'$set': {
        'groupExpenses': expenses,
        'groupParticipants': participants,
      }
    });
  }

  // Deleting the Group
  static Future<bool> deleteGroup(String groupName) async {
    await userCollection.deleteOne({"groupName": groupName});
    return false;
  }

  // Get the group password
  static Future<String> getPassword(String groupName) async {
    var group = await userCollection.findOne({"groupName": groupName});
    return group['groupPassword'];
  }
}
