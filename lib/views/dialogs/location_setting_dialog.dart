import 'package:butler/utils/logging.dart';
import 'package:butler/views/misc/async_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class LocationSettingDialog extends StatefulWidget {
    final Future<void> Function(Location location, String address) onSetLocation;
  final String? initialLocation;

  const LocationSettingDialog({Key? key, required this.onSetLocation, this.initialLocation})
      : super(key: key);

  @override
  State<LocationSettingDialog> createState() => _LocationSettingDialogState();
}

class _LocationSettingDialogState extends State<LocationSettingDialog> with Logging {
  final TextEditingController _textController = TextEditingController();
  final _locationKey = GlobalKey<FormFieldState>();
  Location? _location;

  @override
  void initState() {
    if (widget.initialLocation != null) {
      _textController.text = widget.initialLocation!;
    }
    super.initState();
  }

  Future<bool> _isValidLocation(String address) async {
    try {
      var places = await locationFromAddress(address, localeIdentifier: "en_US");
      logger.fine("# of Places: ${places.length}");
      Location? location = places.singleOrNull;
      if (location != null) {
        _location = location;
        return true;
      }
    } on NoResultFoundException {
      logger.warning("No place found for \"$address\"");
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Location"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            AsyncTextFormField(
              overrideKey: _locationKey,
              hintText: "e.g: Houston, Texas",
              validator: _isValidLocation,
              valueIsInvalidMessage: "Could not find it. Be more precise.",
              controller: _textController,
              onValid: _saveAndCloseForm,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.grey)),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () => _locationKey.currentState!.validate(),
            child: const Text("Submit"))
      ],
    );
  }

  Future<void> _saveAndCloseForm(String text) async {
    if (_location != null) {
      await widget.onSetLocation(
          _location!, text);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

}
