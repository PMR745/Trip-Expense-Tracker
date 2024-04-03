import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_expense_tracker/models/theme.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/providers/theme_provider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/components/side_menu/add_extra_participants.dart';
import 'package:trip_expense_tracker/screens/main_screen.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => Drawer(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 60,
              ),
              const Text(
                "PMR Trip Tracker",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.grey,
              ),
              Text(
                value.getGroupName(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                title: const Text("Add Participants"),
                trailing: const Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddExtraParticipants()));
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("Invite Participants"),
                trailing: const Icon(Icons.person_add_alt_1),
                onTap: () async {
                  final password =
                      await MongoDatabase.getPassword(value.getGroupName());
                  await Share.share(
                    "PMR Trip Tracker App\n\nDownload the App:- link\nGroup Name: ${value.getGroupName()}\nGroup Password: ${password}",
                    subject: "Invitation to Join PMR Trip Tracker App",
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("Share Expenses"),
                trailing: const Icon(Icons.share),
                onTap: () async {
                  double totalAmount = 0;
                  final List groupExpenses =
                      await MongoDatabase.getGroupExpenses(
                          value.getGroupName());
                  final List groupParticipants =
                      await MongoDatabase.getGroupParticipants(
                          value.getGroupName());
                  // print(groupExpenses[0].expenseName);
                  String message =
                      "PMR Trip Tracker\nGroup Name: ${value.getGroupName()} \n\n";

                  groupExpenses.forEach((element) {
                    message +=
                        "  ${element.expenseName} by ${element.expenseDoneBy} of Rs. ${element.expenseAmount}\n";
                    totalAmount += double.parse(element.expenseAmount);
                  });

                  message += "\nTotal Expense: Rs. ${totalAmount}";
                  message +=
                      "\nIndividual Contribution: Rs. ${totalAmount / groupParticipants.length}";
                  // print(message);
                  await Share.share(message);
                },
              ),
              Divider(),
              ListTile(
                title: const Text("Delete Group"),
                trailing: const Icon(Icons.delete),
                onTap: () async {
                  final result = await confirmDeleteBox(context);
                  if (result) {
                    await MongoDatabase.deleteGroup(value.getGroupName());
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove("groupName");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const MainScreen())));
                  }
                },
              ),
              Divider(),
              ListTile(
                title: const Text("Change Theme"),
                trailing:
                    Provider.of<ThemeProvider>(context).themeData == lightMode
                        ? const Icon(Icons.dark_mode)
                        : const Icon(Icons.light_mode),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("Leave Group"),
                trailing: const Icon(
                  Icons.exit_to_app,
                ),
                onTap: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove("groupName");
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                      (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future confirmDeleteBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.info,
          ),
          title: const Text("Are you sure you want to delete group?"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )),
              ),
              const SizedBox(
                width: 30,
              ),
              CustomButton(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
