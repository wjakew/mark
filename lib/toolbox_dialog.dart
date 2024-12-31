import 'package:flutter/material.dart';

class ToolboxDialog extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String) onFormatText;

  ToolboxDialog({required this.onClose, required this.onFormatText});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Toolbox'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextButton(
              child: Text('Bold'),
              onPressed: () => onFormatText('**'),
            ),
            TextButton(
              child: Text('Italic'),
              onPressed: () => onFormatText('*'),
            ),
            // Add more formatting options as needed
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: onClose,
        ),
      ],
    );
  }
} 