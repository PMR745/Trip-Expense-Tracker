import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/components/custom_text_field.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class AddExtraParticipants extends StatefulWidget {
  const AddExtraParticipants({super.key});

  @override
  State<AddExtraParticipants> createState() => _AddExtraParticipantsState();
}

class _AddExtraParticipantsState extends State<AddExtraParticipants> {
  TextEditingController participantNameController = TextEditingController();

  List<String> participantsName = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getParticipantsName();
  }

  Future _getParticipantsName() async {
    var groupName =
        Provider.of<GroupProvider>(context, listen: false).getGroupName();
    final results = await MongoDatabase.getParticipantsName(groupName);
    participantsName = results;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
            leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        )),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                CustomTextField(
                    groupNameController: participantNameController,
                    hintText: "Participant Name"),
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
                        MongoDatabase.addParticipants(
                          value.getGroupName(),
                          participantNameController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "${participantNameController.text} added to group")));
                        setState(() {
                          participantsName
                              .add(participantNameController.text.trim());
                        });
                        participantNameController.text = "";
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
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: participantsName.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey.shade300,
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
