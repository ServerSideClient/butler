import 'package:flutter/material.dart';
import 'package:mobile_assistant/views/home_view.dart';
import 'package:mobile_assistant/layouts/default_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const DefaultLayout(title: "Mobile Assistant", body: HomeView()),
    );
  }
}