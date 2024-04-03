import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/models/group_participants.dart';
import 'package:trip_expense_tracker/models/theme.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/providers/theme_provider.dart';
import 'package:trip_expense_tracker/screens/add_expense_screen.dart';
import 'package:trip_expense_tracker/screens/components/contribution_screen.dart';
import 'package:trip_expense_tracker/screens/components/expense_screen.dart';
import 'package:trip_expense_tracker/screens/components/side_menu/side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String groupName = "";
  List<String> participantsName = ["No Member"];
  List<GroupParticipants> groupParticipants = [];
  List<String> tabs = ["Expense", "Contribution"];

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, value, child) => DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          drawer: const SideMenu(),
          appBar: AppBar(
            title: Text(value.getGroupName()),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
              setState(() {});
            },
            backgroundColor:
                Provider.of<ThemeProvider>(context).themeData == lightMode
                    ? Colors.black
                    : Colors.white,
            child: Icon(
              Icons.add,
              color: Provider.of<ThemeProvider>(context).themeData == lightMode
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                TabBar(
                  labelColor:
                      Provider.of<ThemeProvider>(context).themeData == lightMode
                          ? Colors.black
                          : Colors.white,
                  indicatorColor:
                      Provider.of<ThemeProvider>(context).themeData == lightMode
                          ? Colors.black
                          : Colors.white,
                  tabs: tabs
                      .map(
                        (tab) => Tab(
                          icon: Text(
                            tab,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      ExpenseScreen(),
                      ContributionScreen(),
                    ],
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
