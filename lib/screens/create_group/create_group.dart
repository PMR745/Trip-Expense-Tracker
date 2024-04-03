import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as MongoDart;
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/models/group.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/components/custom_text_field.dart';
import 'package:trip_expense_tracker/screens/create_group/add_particpants.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupPasswordController = TextEditingController();
  bool createGroup = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(builder: ((context, value, child) {
      return Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    "Group Details",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  CustomTextField(
                    groupNameController: groupNameController,
                    hintText: "Group Name",
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextField(
                      groupNameController: groupPasswordController,
                      hintText: "Group Password"),
                  const SizedBox(
                    height: 50,
                  ),
                  CustomButton(
                    child: ElevatedButton(
                        onPressed: () {
                          createGroup = true;
                          setState(() {});
                          if (groupNameController.text.isNotEmpty &&
                              groupPasswordController.text.isNotEmpty) {
                            _createGroup(
                              groupNameController.text.trim(),
                              groupPasswordController.text.trim(),
                            );
                            FocusScope.of(context).unfocus();

                            value.addGroupName(groupNameController.text.trim());
                          } else if (groupNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Group Name cannot be empty")));
                          } else if (groupPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Group Password cannot be empty")));
                          }
                        },
                        child: const Text(
                          "Create Group",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  createGroup
                      ? Column(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text("Creating Group..."),
                          ],
                        )
                      : Text(""),
                ],
              ),
            ),
          ),
        ),
      );
    }));
  }

  void _createGroup(String groupName, String groupPassword) async {
    var checkGroup = await MongoDatabase.getGroup(groupName);
    if (checkGroup == null) {
      var groupId = MongoDart.ObjectId();
      GroupModel group = GroupModel(
        id: groupId,
        groupName: groupName,
        groupPassword: groupPassword,
        groupParticipants: [],
        groupExpenses: [],
      );
      await MongoDatabase.createGroup(group);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AddParticipants()));
    } else {
      setState(() {
        createGroup = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Groupname already exists! Try unique one")));
    }
  }
}
