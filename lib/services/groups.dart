import 'package:mongo_dart/mongo_dart.dart';
import 'package:trip_expense_tracker/models/group.dart';
import 'package:trip_expense_tracker/models/group_participants.dart';

class Groups {
  static List<GroupModel> groups = [];

  static void addGroup(GroupModel group) {
    groups.add(group);
  }

  static List<GroupModel> getGroups() {
    return groups;
  }

  static void addParticipants(
      ObjectId id, GroupParticipants groupParticipants) {
    print(" and ${id}");
    groups.forEach((element) {
      if (element.id == id) {
        element.groupParticipants.add(groupParticipants);
        print("added");
      }
    });
  }

  static void getParticipantsName(String groupName) {
    List<String> names = [];
    groups.forEach((group) {
      if (group.groupName == groupName) {
        group.groupParticipants.forEach((element) {
          names.add(element.participantName);
        });
      }
    });
    print(names);
  }
}
