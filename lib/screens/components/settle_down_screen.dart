import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/models/settle_down.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class SettleDownScreen extends StatefulWidget {
  SettleDownScreen({
    super.key,
    required this.settleDown,
  });
  List<SettleDown> settleDown = [];

  @override
  State<SettleDownScreen> createState() => _SettleDownScreenState();
}

class _SettleDownScreenState extends State<SettleDownScreen> {
  List<SettleDown> settleDown = [];
  List<SettleDown> filterSettleDown = [];

  @override
  void initState() {
    settleDown = widget.settleDown;
    _getSettleDowns();
    filter();
  }

  void _getSettleDowns() async {
    final groupName =
        Provider.of<GroupProvider>(context, listen: false).getGroupName();

    List<SettleDown> results = await MongoDatabase.getSettleDown(groupName);
    if (results.isNotEmpty) {
      settleDown = results;
    }
  }

  void _updateSettleDowns() async {
    final groupName =
        Provider.of<GroupProvider>(context, listen: false).getGroupName();
    await MongoDatabase.addSettleDown(groupName, settleDown);
  }

  void filter() async {
    if (filterSettleDown.isEmpty) {
      settleDown.forEach((element) {
        if (element.done == false) {
          filterSettleDown.add(element);
        }
      });
      settleDown.forEach((element) {
        if (element.done == true) {
          filterSettleDown.add(element);
        }
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Provider.of<GroupProvider>(context, listen: false).getGroupName(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Divider(),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Settle Down",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filterSettleDown.length,
                  itemBuilder: (context, index) {
                    final item = filterSettleDown[index];
                    return ListTile(
                      leading: Checkbox(
                        value: item.done,
                        onChanged: (bool? value) {
                          setState(() {
                            item.done = value!;
                            filter();
                            _updateSettleDowns();
                          });
                        },
                      ),
                      title: Text(
                        "${item.from} to ${item.to} Rs. ${item.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          decoration: item.done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
