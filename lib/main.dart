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
import 'package:flutter/widgets.dart'; // Import for Image widget

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

class _TabInfo {
  final GlobalKey<MarkdownEditorScreenState> key;
  final Widget widget;
  String content;

  _TabInfo({
    required this.key,
    required this.widget,
    this.content = '',
  });
}

class MarkdownEditorHome extends StatefulWidget {
  @override
  _MarkdownEditorHomeState createState() => _MarkdownEditorHomeState();
}

class _MarkdownEditorHomeState extends State<MarkdownEditorHome> with TickerProviderStateMixin {
  List<_TabInfo> tabs = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 0,
      vsync: this,
    )..addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.previousIndex >= 0 && _tabController.previousIndex < tabs.length) {
        final previousTab = tabs[_tabController.previousIndex];
        previousTab.content = previousTab.key.currentState?.getCurrentText() ?? '';
      }
    }
  }

  void _createNewTab() {
    final key = GlobalKey<MarkdownEditorScreenState>();
    setState(() {
      tabs.add(
        _TabInfo(
          key: key,
          widget: MarkdownEditorScreen(
            key: key,
            initialText: '',
            onTextChanged: (text) {
              tabs[tabs.length - 1].content = text;
            },
            onCreateNewTab: _createNewTab,
          ),
        ),
      );
      _tabController = TabController(
        length: tabs.length,
        vsync: this,
        initialIndex: tabs.length - 1,
      )..addListener(_handleTabChange);
    });
  }

  void _removeTab(int index) {
    setState(() {
      tabs.removeAt(index);
      if (tabs.isEmpty) {
        _tabController = TabController(length: 0, vsync: this);
      } else {
        _tabController = TabController(
          length: tabs.length,
          vsync: this,
          initialIndex: index > 0 ? index - 1 : 0,
        )..addListener(_handleTabChange);
      }
    });
  }

  void _deleteAllTabs() {
    setState(() {
      tabs.clear();
      _tabController = TabController(length: 0, vsync: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: AppBar().preferredSize.height,
            )
          ],
        ),
        backgroundColor: Color(0xFF4A171E),
        bottom: tabs.isEmpty ? null : TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFFFFF29),
          labelColor: Color(0xFFFFFF29),
          unselectedLabelColor: Colors.white,
          tabs: List.generate(
            tabs.length,
            (index) => Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('File ${index + 1}'),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => _removeTab(index),
                    child: Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (tabs.isNotEmpty)
            IconButton(
              icon: Icon(Icons.add, color: Color(0xFFFFFF29)),
              onPressed: _createNewTab,
              tooltip: 'Add new tab',
            ),
          if (tabs.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Color(0xFFFFFF29)),
              onPressed: _deleteAllTabs,
              tooltip: 'Delete all tabs',
            ),
        ],
      ),
      body: tabs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    iconSize: 64,
                    color: Colors.white,
                    onPressed: _createNewTab,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Create New Tab',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: tabs.map((tab) => tab.widget).toList(),
            ),
    );
  }
}
