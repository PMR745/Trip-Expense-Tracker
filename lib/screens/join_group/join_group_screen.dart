import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/components/custom_text_field.dart';
import 'package:trip_expense_tracker/screens/home_screen.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class JoinGroupScreen extends StatelessWidget {
  JoinGroupScreen({super.key});
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
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
                    hintText: "Group Password",
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomButton(
                    child: ElevatedButton(
                        onPressed: () async {
                          var result = await MongoDatabase.getGroup(
                              groupNameController.text.trim());
                          if (result == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Group doesn't exists!")));
                          } else if (result['groupPassword'] ==
                              groupPasswordController.text.trim()) {
                            if (await MongoDatabase.joinGroup(
                                groupNameController.text.trim(),
                                groupPasswordController.text.trim())) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen()));

                              FocusScope.of(context).unfocus();
                              value.addGroupName(
                                  groupNameController.text.trim());
                            } else {
                              print("Something went wrong");
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Wrong Password! Try Again")));
                          }
                        },
                        child: const Text(
                          "Join Group",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
