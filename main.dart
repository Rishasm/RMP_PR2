import 'package:flutter/material.dart';

void main() => runApp(const NotesApp());

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _notes = [];
  int? _editingIndex;
  String? _errorText;

  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Введите текст заметки');
      return;
    }
    setState(() {
      if (_editingIndex == null) {
        _notes.add(text);
      } else {
        _notes[_editingIndex!] = text;
      }
      _editingIndex = null;
      _errorText = null;
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _editNote(int index) {
    setState(() {
      _editingIndex = index;
      _errorText = null;
      _controller.text = _notes[index];
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _errorText = null;
      _controller.clear();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
        _errorText = null;
        _controller.clear();
      } else if (_editingIndex != null && index < _editingIndex!) {
        _editingIndex = _editingIndex! - 1;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editingIndex == null
                    ? 'Новая заметка'
                    : 'Редактирование заметки',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Текст заметки',
                  hintText: 'Введите заметку',
                  border: const OutlineInputBorder(),
                  errorText: _errorText,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Сохранить'),
                  ),
                  if (_editingIndex != null)
                    TextButton(
                      onPressed: _cancelEditing,
                      child: const Text('Отмена'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Список заметок (${_notes.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _notes.isEmpty
                    ? const Center(child: Text('Пока нет заметок'))
                    : ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(_notes[index]),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        tooltip: 'Редактировать',
                                        onPressed: () => _editNote(index),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Удалить',
                                        onPressed: () => _deleteNote(index),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
