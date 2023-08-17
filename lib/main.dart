import 'package:butler/views/dropdowns/top_bar_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:butler/views/home_view.dart';
import 'package:butler/layouts/default_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butler',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const DefaultLayout(
          title: "Butler",
          topBarActions: [TopBarDropdown()],
          children: [HomeView()]),
    );
  }
}
