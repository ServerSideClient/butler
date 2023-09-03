import 'package:butler/layouts/default_layout.dart';
import 'package:butler/utils/shared_preferences_helper.dart';
import 'package:butler/views/dialogs/directories_selection_dialog.dart';
import 'package:butler/views/dialogs/location_setting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class SettingsView extends StatelessWidget with SharedPreferencesAccess {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: "Settings",
      centered: false,
      topPadding: 32.0,
      horizontalPadding: 16,
      children: [
        _buildSettingsRow(
            "Location",
            ElevatedButton(
                onPressed: () async => await _showLocationChangeDialog(context),
                child: const Text("Change"))),
        _buildSettingsRow(
            "Ringtones",
            ElevatedButton(
                onPressed: () async => await _showRingtoneChangeDialog(context),
                child: const Text("Assign"))),
      ],
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

  Future<void> _showLocationChangeDialog(BuildContext context) async {
    var currentAddress =
        prefs.getString(SharedPreferencesHelper.keySettingAddress);
    await showDialog(
        context: context,
        builder: (_) => LocationSettingDialog(
              onSetLocation: _setLocationSetting,
              initialLocation: currentAddress,
            ));
  }

  Future<void> _setLocationSetting(Location location, String address) async {
    await prefs.setString(SharedPreferencesHelper.keySettingAddress, address);
    await prefs.setDouble(
        SharedPreferencesHelper.keySettingLongitude, location.longitude);
    await prefs.setDouble(
        SharedPreferencesHelper.keySettingLatitude, location.latitude);
  }

  Future<void> _showRingtoneChangeDialog(BuildContext context) async {
    var dirs = prefs.getStringList(
            SharedPreferencesHelper.keySettingRingtoneDirectory) ??
        [];
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => DirectoriesSelectionDialog(
            initialDirectories: dirs, onSubmit: _setRingtoneDirectories));
  }

  Future<void> _setRingtoneDirectories(List<String> directories) async {
    await prefs.setStringList(
        SharedPreferencesHelper.keySettingRingtoneDirectory, directories);
  }
}
