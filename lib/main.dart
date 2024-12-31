import 'dart:io'; // Import for File operations
import 'package:path_provider/path_provider.dart'; // Import for path provider
import 'package:file_saver/file_saver.dart'; // Import for file saving
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:typed_data'; // Import for Uint8List
import 'package:file_picker/file_picker.dart'; // Import for file picking

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MarkdownEditorApp());
}

class MarkdownEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mark.',
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
  bool _isMarkdownVisible = true;

  Future<void> _saveMarkdownFile() async {
    // Open file picker for user to select the file path and name
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Markdown File',
      fileName: 'markdown_file.md',
    );

    if (filePath != null) {
      await File(filePath).writeAsString(_text);
      
      Uint8List data = Uint8List.fromList(_text.codeUnits);
      
      await FileSaver.instance.saveFile('markdown_file.md', data, 'md');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to $filePath')),
      );
    }
  }

  void _updateMarkdown(String newText) {
    setState(() {
      _text = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mark.'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveMarkdownFile,
          ),
          IconButton(
            icon: Icon(_isMarkdownVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _isMarkdownVisible = !_isMarkdownVisible;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    onChanged: _updateMarkdown,
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
    );
  }
}
