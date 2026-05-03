import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_editor_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_color_picker.dart';

class NoteEditorPage extends StatefulWidget {
  final int noteId;

  const NoteEditorPage({
    super.key,
    required this.noteId,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final NoteEditorController _controller;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _controller = NoteEditorController(
      repository: NoteRepository(),
      noteId: widget.noteId,
    );
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final result = await _controller.loadNote();
    if (!mounted) return;

    if (!result.$1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.$2 ?? 'Falha ao carregar nota')),
      );
      return;
    }

    _titleController.text = _controller.title;
    _descriptionController.text = _controller.description;
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    _controller.setTitle(_titleController.text);
    _controller.setDescription(_descriptionController.text);

    final result = await _controller.save();
    if (!mounted) return;

    if (!result.$1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.$2 ?? 'Falha ao salvar nota')),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFDF2F8),
          appBar: AppBar(
            title: const Text('Editar nota'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: _controller.isSaving ? null : _saveAndExit,
                child: const Text('Sair'),
              ),
            ],
          ),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 12,
                        decoration: const InputDecoration(
                          labelText: 'Conteúdo',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cor da nota',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FolderColorPicker(
                          selected: _controller.color,
                          onSelect: _controller.setColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _controller.isSaving ? null : _saveAndExit,
                          icon: _controller.isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(_controller.isSaving ? 'Salvando...' : 'Salvar e sair'),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
