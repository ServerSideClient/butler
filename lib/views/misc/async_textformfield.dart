import 'dart:async';

import 'package:flutter/material.dart';

class AsyncTextFormField extends StatefulWidget {
  final Future<bool> Function(String) validator;
  final String hintText;
  final String isValidatingMessage;
  final String valueIsEmptyMessage;
  final String valueIsInvalidMessage;
  final TextEditingController controller;
  final Duration? validationDebounce;
  final Key? overrideKey;
  final Future<void> Function(String value)? onValid;

  const AsyncTextFormField(
      {Key? key,
      required this.validator,
      required this.controller,
      this.validationDebounce,
      this.isValidatingMessage = "Validation in progress",
      this.valueIsEmptyMessage = "Empty text is not permitted",
      this.valueIsInvalidMessage = "Text is not valid",
      this.hintText = "",
      this.onValid,
      this.overrideKey})
      : super(key: key);

  @override
  State<AsyncTextFormField> createState() => _AsyncTextFormFieldState();
}

class _AsyncTextFormFieldState extends State<AsyncTextFormField> {
  Timer? _debounce;
  var isValidating = false;
  var isValid = false;
  var isDirty = false;
  var isWaiting = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.overrideKey,
      autovalidateMode: (widget.validationDebounce != null)
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: (value) {
        if (isValidating) {
          return widget.isValidatingMessage;
        }
        if (value?.isEmpty ?? false) {
          return widget.valueIsEmptyMessage;
        } else if (value != null &&
            !isWaiting &&
            widget.validationDebounce == null) {
          isWaiting = true;
          validate(value).then((valid) {
            setState(() => isValid = valid);
            if (isValid && widget.onValid != null) {
              Future.delayed(const Duration(seconds: 1)).then((_) async {
                await widget.onValid!(value);
              });
            } else {
              setState(() => isWaiting = false);
            }
          });
          return null;
        }
        if (!isWaiting && !isValid) {
          return widget.valueIsInvalidMessage;
        }
        return null;
      },
      controller: widget.controller,
      onChanged: (text) async {
        if (widget.validationDebounce != null) {
          isDirty = true;
          if (text.isEmpty) {
            setState(() {
              isValid = false;
            });
            cancelTimer();
            return;
          }
          isWaiting = true;
          cancelTimer();
          _debounce = Timer(widget.validationDebounce!, () async {
            isWaiting = false;
            isValid = await validate(text);
            setState(() {});
            isValidating = false;
          });
        }
      },
      textAlign: TextAlign.start,
      maxLines: 1,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          suffix: SizedBox(height: 20, width: 20, child: _getSuffixIcon()),
          hintText: widget.hintText),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void cancelTimer() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
  }

  Future<bool> validate(String text) async {
    setState(() {
      isValidating = true;
    });
    final isValid = await widget.validator(text);
    isValidating = false;
    return isValid;
  }

  Widget _getSuffixIcon() {
    if (isValidating) {
      return const CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation(Colors.blue),
      );
    } else {
      if (!isValid && isDirty) {
        return const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 20,
        );
      } else if (isValid) {
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        );
      } else {
        return Container();
      }
    }
  }
}
