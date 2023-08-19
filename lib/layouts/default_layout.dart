import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool centered;
  final Widget? floatingActionButton;
  final List<Widget>? topBarActions;
  final double topPadding;
  final double horizontalPadding;

  const DefaultLayout(
      {Key? key,
      required this.title,
      required this.children,
      this.centered = false,
      this.topPadding = 0.0,
      this.horizontalPadding = 0.0,
      this.topBarActions,
      this.floatingActionButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: topBarActions,
      ),
      body: (centered)
          ? Center(
              child: SingleChildScrollView(
              child: buildChild(),
            ))
          : SingleChildScrollView(child: buildChild()),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget buildChild() {
    Widget child = Column(
      children: children,
    );
    if (topPadding > 0.0 || horizontalPadding > 0.0) {
      child = Padding(
          padding: EdgeInsets.only(
              top: topPadding,
              left: horizontalPadding,
              right: horizontalPadding),
          child: child);
    }
    return child;
  }
}
