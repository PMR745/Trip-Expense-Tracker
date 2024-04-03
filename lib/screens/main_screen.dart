import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/screens/components/custom_button.dart';
import 'package:trip_expense_tracker/screens/create_group/create_group.dart';
import 'package:trip_expense_tracker/screens/home_screen.dart';
import 'package:trip_expense_tracker/screens/join_group/join_group_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    groupJoined();
  }

  Future groupJoined() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final groupName = prefs.getString("groupName");
    if (groupName != "" && groupName != null) {
      Provider.of<GroupProvider>(context, listen: false)
          .addGroupName(groupName);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/img/main-bg.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        "PMR",
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "Trip Tracker",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 2.2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "~",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                "\"Explore the world, without breaking the bank\"",
                                style: GoogleFonts.arvo(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomButton(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateGroupScreen()));
                            },
                            child: const Text(
                              "Create Group",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomButton(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => JoinGroupScreen()));
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
