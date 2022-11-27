import 'package:flutter/material.dart';

class DefaultLayout extends StatefulWidget {

  final String title;
  final Widget body;
  final bool centered;

  const DefaultLayout({Key? key, required this.title, required this.body, this.centered = true}) : super(key: key);

  @override
  State<DefaultLayout> createState() => _LayoutState();
}

class _LayoutState extends State<DefaultLayout> {
  @override
  Widget build(BuildContext context) {
    Widget bodyToDisplay;
    if (widget.centered) {
      bodyToDisplay = Center(
        child: widget.body,
      );
    }
    else {
      bodyToDisplay = widget.body;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: bodyToDisplay,
    );
  }
}
