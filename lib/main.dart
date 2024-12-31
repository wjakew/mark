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
        primarySwatch: Colors.yellow,
        fontFamily: 'Courier',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        fontFamily: 'Courier',
      ),
      themeMode: ThemeMode.dark,
      home: MarkdownEditorHome(),
    );
  }
}

class MarkdownEditorHome extends StatefulWidget {
  @override
  _MarkdownEditorHomeState createState() => _MarkdownEditorHomeState();
}

class _MarkdownEditorHomeState extends State<MarkdownEditorHome> with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> _tabContents = [''];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  void _updateTabContent(int index, String newContent) {
    setState(() {
      _tabContents[index] = newContent;
    });
  }

  void _addNewTab() {
    setState(() {
      _tabContents.add('');
      _currentIndex = _tabContents.length - 1;
      _tabController = TabController(
        length: _tabContents.length,
        vsync: this,
        initialIndex: _currentIndex,
      );
      _tabController.addListener(_handleTabChange);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mark.'),
        bottom: TabBar(
          controller: _tabController,
          tabs: List.generate(_tabContents.length, (index) => Tab(text: 'Tab ${index + 1}')),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewTab,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          _tabContents.length,
          (index) => MarkdownEditorScreen(
            key: ValueKey(index),
            initialText: _tabContents[index],
            onTextChanged: (text) => _updateTabContent(index, text),
          ),
        ),
      ),
    );
  }
}

class MarkdownEditorScreen extends StatefulWidget {
  final String initialText;
  final String? initialFilePath;
  final Function(String)? onTextChanged;

  MarkdownEditorScreen({
    Key? key,
    this.initialText = '',
    this.initialFilePath,
    this.onTextChanged,
  }) : super(key: key);

  @override
  _MarkdownEditorScreenState createState() => _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends State<MarkdownEditorScreen> {
  late String _text;
  bool _isMarkdownVisible = false;
  String? _currentFilePath;
  final TextEditingController _controller = TextEditingController();

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
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    onChanged: _handleTextChange, // Use the new handler
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Dropdown Menu for Open, Save, and Preview
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as needed
            items: [
              PopupMenuItem<String>(
                value: 'Open',
                child: Text('Open'),
              ),
              PopupMenuItem<String>(
                value: 'Save',
                child: Text('Save'),
              ),
              PopupMenuItem<String>(
                value: 'Preview',
                child: Text('Preview'),
              ),
            ],
          ).then((value) {
            if (value != null) {
              if (value == 'Open') {
                _openMarkdownFile();
              } else if (value == 'Save') {
                _saveMarkdownFile();
              } else if (value == 'Preview') {
                setState(() {
                  _isMarkdownVisible = !_isMarkdownVisible; // Toggle visibility
                });
              }
            }
          });
        },
        child: Icon(Icons.more_vert), // Icon for the actions button
      ),
    );
  }
}
