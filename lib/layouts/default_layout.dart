import 'package:flutter/material.dart';

class DefaultLayout extends StatefulWidget {
  final String title;
  final Widget body;
  final bool centered;

  const DefaultLayout(
      {Key? key, required this.title, required this.body, this.centered = true})
      : super(key: key);

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: (widget.centered)
          ? Center(
              child: widget.body,
            )
          : widget.body,
    );
  }
}
