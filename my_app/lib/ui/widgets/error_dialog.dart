import 'package:flutter/material.dart';

void showErrorDialog(
  BuildContext context,
  String message,
  VoidCallback onClear,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ошибка'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            onClear();
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
