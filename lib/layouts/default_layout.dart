import 'package:flutter/material.dart';

class DefaultLayout extends StatefulWidget {

  final String title;
  final Widget body;

  const DefaultLayout({Key? key, required this.title, required this.body}) : super(key: key);

  @override
  State<DefaultLayout> createState() => _LayoutState();
}

class _LayoutState extends State<DefaultLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widget.body,
    );
  }
}
