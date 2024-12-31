import 'dart:io'; // Import for File operations
import 'package:path_provider/path_provider.dart'; // Import for path provider
import 'package:file_saver/file_saver.dart'; // Import for file saving
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:typed_data'; // Import for Uint8List
import 'package:file_picker/file_picker.dart'; // Import for file picking
import 'package:path/path.dart' as path; // Use a prefix for path manipulation

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MarkdownEditorApp());
}

class MarkdownEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mark.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Courier',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Courier',
      ),
      themeMode: ThemeMode.system,
      home: MarkdownEditorScreen(),
    );
  }
}

class MarkdownEditorScreen extends StatefulWidget {
  @override
  _MarkdownEditorScreenState createState() => _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends State<MarkdownEditorScreen> {
  String _text = '';
  bool _isMarkdownVisible = false;
  String? _currentFilePath; // Variable to store the current file path
  final TextEditingController _controller = TextEditingController(); // TextEditingController

  @override
  void initState() {
    super.initState();
    _controller.text = _text; // Initialize the controller with the current text
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
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

  Future<void> _saveMarkdownFile() async {
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

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(), // Create a focus node to listen for keyboard events
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.controlLeft) {
          // Check if the 'O' key is pressed while holding 'Ctrl'
          setState(() {
            _isMarkdownVisible = !_isMarkdownVisible; // Toggle visibility
          });
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0), // Set the height of the AppBar
          child: AppBar(
            title: Text('mark.'),
            actions: [
              // Dropdown Menu for Open, Save, and Preview
              PopupMenuButton<String>(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text('Actions'), // Label for the dropdown menu
                      Icon(Icons.arrow_drop_down), // Dropdown icon
                    ],
                  ),
                ),
                onSelected: (value) {
                  if (value == 'Open') {
                    _openMarkdownFile();
                  } else if (value == 'Save') {
                    _saveMarkdownFile();
                  } else if (value == 'Preview') {
                    setState(() {
                      _isMarkdownVisible = !_isMarkdownVisible; // Toggle visibility
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Open', 'Save', 'Preview'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controller, // Use the controller
                      onChanged: (newText) {
                        setState(() {
                          _text = newText; // Update _text when the text changes
                        });
                      },
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your markdown text here...',
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
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Markdown(
                    data: _text,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
