import 'dart:io'; // Import for File operations
import 'package:path_provider/path_provider.dart'; // Import for path provider
import 'package:file_saver/file_saver.dart'; // Import for file saving
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:typed_data'; // Import for Uint8List
import 'package:file_picker/file_picker.dart'; // Import for file picking
import 'package:path/path.dart' as path; // Use a prefix for path manipulation
import 'markdown_editor_screen.dart'; // Import the new file

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
  final int _maxTabs = 7; // Maximum number of tabs allowed

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
    if (_tabContents.length < _maxTabs) {
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
    } else {
      // Show dialog when trying to add more than the maximum allowed tabs
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Limit Reached'),
            content: Text('You can only have a maximum of $_maxTabs open tabs.'),
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
    }
  }

  void _closeTab(int index) {
    if (_tabContents.length > 1) { // Ensure at least one tab remains
      setState(() {
        _tabContents.removeAt(index); // Remove the content
        if (_currentIndex >= index) {
          _currentIndex = (_currentIndex > 0) ? _currentIndex - 1 : 0; // Adjust current index
        }
        _tabController = TabController(
          length: _tabContents.length,
          vsync: this,
          initialIndex: _currentIndex,
        );
        _tabController.addListener(_handleTabChange);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mark.'),
        bottom: TabBar(
          controller: _tabController,
          tabs: List.generate(_tabContents.length, (index) {
            return Tab(
              child: Row(
                children: [
                  Text('File ${index + 1}'),
                  IconButton(
                    icon: Icon(Icons.close, size: 16),
                    onPressed: () => _closeTab(index), // Close tab on button press
                  ),
                ],
              ),
            );
          }),
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
