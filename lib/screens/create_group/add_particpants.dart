import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/components/custom_text_field.dart';
import 'package:trip_expense_tracker/screens/home_screen.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class AddParticipants extends StatefulWidget {
  const AddParticipants({super.key});

  @override
  State<AddParticipants> createState() => _AddParticipantsState();
}

class _AddParticipantsState extends State<AddParticipants> {
  TextEditingController participantNameController = TextEditingController();
  List<String> participantsName = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        child: Text(
                          value.getGroupName(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    CustomButton(
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                        child: const Text(
                          "Create",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomTextField(
                  groupNameController: participantNameController,
                  hintText: "Participant Name",
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomButton(
                  child: ElevatedButton(
                    onPressed: () {
                      if (participantNameController.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Participant name cannot be empty")));
                      } else {
                        FocusScope.of(context).unfocus();
                        MongoDatabase.addParticipants(
                          value.getGroupName(),
                          participantNameController.text,
                        );
                        setState(() {
                          participantsName
                              .add(participantNameController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text(
                                  "${participantNameController.text} added to group")));
                          participantNameController.text = "";
                        });
                      }
                    },
                    child: const Text(
                      "Add Participant",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: participantsName.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        shadowColor: Colors.white,
                        margin: const EdgeInsets.only(
                          top: 10,
                        ),
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8),
                          child: Text(
                            participantsName[index],
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
