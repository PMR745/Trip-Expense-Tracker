import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/models/group_participants.dart';
import 'package:trip_expense_tracker/models/settle_down.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/components/settle_down_screen.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  String groupName = "";
  double totalAmount = 0.0;
  double contri = 0.0;
  List<GroupParticipants> groupParticipants = [];
  List<SettleDown> settleDown = [];

  @override
  void initState() {
    super.initState();
    _getParticipants();
  }

  Future _getParticipants() async {
    var groupName =
        Provider.of<GroupProvider>(context, listen: false).getGroupName();
    final results = await MongoDatabase.getGroupParticipants(groupName);
    results.forEach((element) {
      totalAmount += element.amountExpended;
    });
    groupParticipants = results;
    contri = (totalAmount / results.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Total Contri: Rs. ${contri.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: groupParticipants.length,
                  itemBuilder: (context, index) {
                    var currentParticipant = groupParticipants[index];
                    return ListTile(
                      title: Text(currentParticipant.participantName),
                      subtitle: Text(
                          "Rs. ${currentParticipant.amountExpended.toStringAsFixed(2)}"),
                      trailing: Text(
                        "Rs. ${(currentParticipant.amountExpended - contri).toStringAsFixed(2)}",
                        style: TextStyle(
                          color:
                              (currentParticipant.amountExpended - contri) >= 0
                                  ? Color.fromARGB(255, 1, 160, 6)
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomButton(
                  child: ElevatedButton(
                    onPressed: () {
                      if (settleDown.isEmpty) {
                        _settleDown();
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettleDownScreen(
                                    settleDown: settleDown,
                                  )));
                    },
                    child: const Text(
                      "Settle Down",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _settleDown() {
    List<double> contributions = [];
    groupParticipants.forEach((element) {
      contributions.add(element.amountExpended - contri);
    });

    for (var i = 0; i < contributions.length; i++) {
      for (var j = i + 1; j < contributions.length; j++) {
        if (contributions[i] < 0 && contributions[j] > 0) {
          var amount = 0.0;
          if (contributions[i].abs() > contributions[j].abs()) {
            amount = contributions[j].abs();
            contributions[i] += amount;
            contributions[j] -= amount;
          } else {
            amount = contributions[i].abs();
            contributions[i] += amount;
            contributions[j] -= amount;
          }
          settleDown.add(SettleDown(
            from: groupParticipants[i].participantName,
            to: groupParticipants[j].participantName,
            amount: amount,
            done: false,
          ));
        } else if (contributions[i] > 0 && contributions[j] < 0) {
          var amount = 0.0;
          if (contributions[i].abs() > contributions[j].abs()) {
            amount = contributions[j].abs();
            contributions[j] += amount;
            contributions[i] -= amount;
          } else {
            amount = contributions[i].abs();
            contributions[j] += amount;
            contributions[i] -= amount;
          }
          settleDown.add(SettleDown(
            from: groupParticipants[j].participantName,
            to: groupParticipants[i].participantName,
            amount: amount,
            done: false,
          ));
        }
      }
    }
    setState(() {});
  }
}
