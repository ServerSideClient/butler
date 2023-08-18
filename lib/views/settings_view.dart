import 'package:butler/layouts/default_layout.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DefaultLayout(
      title: "Settings",
      topPadding: 32.0,
      horizontalPadding: 16,
      children: [],
    );
  }

  Widget _buildSettingsRow(String label, Widget settingWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), settingWidget],
      ),
    );
  }
}
