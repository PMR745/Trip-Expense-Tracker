import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/models/group_expense.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/components/custom_text_field.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  TextEditingController expenseName = TextEditingController();
  TextEditingController expenseAmount = TextEditingController();
  String group = "";
  String dropDownValue = "abc";
  List<String> groupParticipantsName = [];

  @override
  void initState() {
    super.initState();
    _getParticipantsName();
  }

  Future _getParticipantsName() async {
    var groupName =
        Provider.of<GroupProvider>(context, listen: false).getGroupName();
    final results = await MongoDatabase.getParticipantsName(groupName);
    groupParticipantsName = results;
    dropDownValue = results[0];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Add Expense",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextField(
                      groupNameController: expenseName,
                      hintText: "Expense name"),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextField(
                      groupNameController: expenseAmount,
                      numKeyboardType: true,
                      hintText: "Expense amount"),
                  const SizedBox(
                    height: 30,
                  ),
                  DropdownButton(
                      value: dropDownValue,
                      items: groupParticipantsName.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownValue = newValue!;
                        });
                      }),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomButton(
                    child: ElevatedButton(
                        onPressed: () {
                          GroupExpense expense = GroupExpense(
                              expenseName: expenseName.text.trim(),
                              expenseAmount: expenseAmount.text.trim(),
                              expenseDoneBy: dropDownValue,
                              timeOfExpense: DateTime.now());
                          value.addGroupExpense(expense);
                          MongoDatabase.addGroupExpense(
                            value.groupName,
                            expense,
                          );
                          setState(() {});
                          Navigator.pop(context, expense);
                        },
                        child: const Text(
                          "Add Expense",
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
