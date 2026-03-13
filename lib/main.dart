import 'package:flutter/material.dart';

import 'screens/checkin_screen.dart';
import 'screens/finish_class_screen.dart';
import 'screens/home_screen.dart';
import 'screens/records_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SmartClassApp());
}

class SmartClassApp extends StatelessWidget {
  const SmartClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Class Check-in',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        CheckInScreen.routeName: (_) => const CheckInScreen(),
        FinishClassScreen.routeName: (_) => const FinishClassScreen(),
        RecordsScreen.routeName: (_) => const RecordsScreen(),
      },
    );
  }
}
