import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';

class MiniTdApp extends StatelessWidget {
  const MiniTdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Tower Defense',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
