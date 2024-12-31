import 'dart:io'; // Import for File operations
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart'; // Import for file picking
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Import the SpeedDial package
import 'toolbox_dialog.dart'; // Import the ToolboxDialog

class MarkdownEditorScreen extends StatefulWidget {
  final String initialText;
  final String? initialFilePath;
  final Function(String)? onTextChanged;
  final VoidCallback? onCreateNewTab;
  final Function(String)? onTabFocusLost;

  MarkdownEditorScreen({
    Key? key,
    this.initialText = '',
    this.initialFilePath,
    this.onTextChanged,
    this.onCreateNewTab,
    this.onTabFocusLost,
  }) : super(key: key);

  @override
  MarkdownEditorScreenState createState() => MarkdownEditorScreenState();
}

class MarkdownEditorScreenState extends State<MarkdownEditorScreen> with AutomaticKeepAliveClientMixin {
  late String _text;
  bool _isMarkdownVisible = false;
  String? _currentFilePath;
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _text = widget.initialText;
    _controller.text = _text;
  }

  @override
  void didUpdateWidget(MarkdownEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText) {
      _text = widget.initialText;
      _controller.text = _text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange(String newText) {
    setState(() {
      _text = newText;
      widget.onTextChanged?.call(newText);
    });
  }

  Future<void> _openMarkdownFile() async {
    // Open file picker for user to select a markdown file
    String? filePath = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md'],
    ).then((result) => result?.files.single.path);

    if (filePath != null) {
      String fileContent = await File(filePath).readAsString();
      setState(() {
        _text = fileContent; // Load content into the text field
        _currentFilePath = filePath; // Store the current file path
        _controller.text = _text; // Update the controller's text
      });
    }
  }

  Future<void> _openToolbox() async {
    // Open a new screen with the toolbox
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ToolboxDialog(
          onClose: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          onFormatText: (String format) {
            // Implement the logic to format the selected text
            // For example, you might want to insert the format around the selected text
          },
        );
      },
    );
  }

  Future<void> _saveMarkdownFile() async {
    if (widget.initialText.isEmpty) {
      // Show a message or dialog indicating that the text field is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Empty Field'),
            content: Text('Cannot save an empty file. Please enter some text.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function if the text is empty
    }
    
    // Check if a file is currently open
    if (_currentFilePath != null) {
      await File(_currentFilePath!).writeAsString(_controller.text); // Use controller's text
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to $_currentFilePath')),
      );
    } else {
      // Open file picker for user to select the file path and name
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Markdown File',
        fileName: 'markdown_file.md',
      );

      if (filePath != null) {
        await File(filePath).writeAsString(_controller.text); // Use controller's text
        _currentFilePath = filePath; // Update current file path
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to $filePath')),
        );
      }
    }
  }

  String getCurrentText() {
    return _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A171E),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _controller,
                            onChanged: _handleTextChange,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'write a story...',
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Word Count: ${_text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isMarkdownVisible)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF174A43),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Markdown(
                  data: _text,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        backgroundColor: Color(0xFFFFF629),
        children: [
          SpeedDialChild(
            child: Icon(Icons.open_in_new, color: Color(0xFFFFFF29)),
            label: 'Open',
            onTap: _openMarkdownFile,
          ),
          SpeedDialChild(
            child: Icon(Icons.save, color: Color(0xFFFFFF29)),
            label: 'Save',
            onTap: _saveMarkdownFile,
          ),
          SpeedDialChild(
            child: Icon(Icons.remove_red_eye, color: Color(0xFFFFFF29)),
            label: 'Preview',
            onTap: () {
              setState(() {
                _isMarkdownVisible = !_isMarkdownVisible; // Toggle visibility
              });
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.handyman, color: Color(0xFFFFFF29)),
            label: 'Toolbox',
            onTap: _openToolbox,
          ),
        ],
      ),
    );
  }
} 