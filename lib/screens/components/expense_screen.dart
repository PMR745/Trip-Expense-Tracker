import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_expense_tracker/models/group_expense.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<GroupExpense> groupExpenses = [];
  @override
  void initState() {
    super.initState();
    getExpenses();
  }

  void getExpenses() async {
    final groupName =
        Provider.of<GroupProvider>(context, listen: false).getGroupName();
    final results = await MongoDatabase.getGroupExpenses(groupName);
    groupExpenses = results;
    Provider.of<GroupProvider>(context, listen: false)
        .addGroupExpenses(results);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("groupName", groupName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (value.getGroupExpense().isEmpty)
                const Text("No Expense added"),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: value.getGroupExpense().length,
                itemBuilder: (context, index) {
                  var expense = value.getGroupExpense()[index];
                  return ListTile(
                    title: Text(expense.expenseName),
                    subtitle: Text("by ${expense.expenseDoneBy}"),
                    trailing: Text(
                      "Rs. ${expense.expenseAmount}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onLongPress: () async {
                      final result = await confirmDeleteBox(context);
                      if (result) {
                        value.deleteGroupExpense(index);
                        MongoDatabase.deleteGroupExpense(
                            value.getGroupName(), index, expense);
                      }
                    },
                  );
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
          title: const Text("Are you sure you want to expense?"),
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
