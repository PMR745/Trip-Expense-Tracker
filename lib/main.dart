import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_expense_tracker/providers/groupProvider.dart';
import 'package:trip_expense_tracker/providers/theme_provider.dart';
import 'package:trip_expense_tracker/screens/main_screen.dart';
import 'package:trip_expense_tracker/services/mongo_database.dart';

/// Set when Firebase fails to initialise, so the failure is visible in the app
/// instead of only in the logs.
String? firebaseInitError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is initialised before runApp so auth state is available to the
  // first frame. A failure here must never prevent the app from launching, so
  // it is recorded and surfaced rather than thrown.
  //
  // On Android the configuration is read from android/app/google-services.json,
  // so no explicit FirebaseOptions are needed.
  try {
    await Firebase.initializeApp();
  } catch (error) {
    firebaseInitError = error.toString();
    debugPrint('Firebase initialisation failed: $error');
  }

  await MongoDatabase.connect();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GroupProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
