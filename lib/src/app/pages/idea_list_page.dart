import 'package:flutter/material.dart';

import '../../features/diagrams/pages/diagrams_sub_page.dart';
import '../../features/notas/pages/notes_sub_page.dart';
import '../../shared/widgets/funcoes_busca.dart';
import '../../shared/widgets/buttons/ideas_toggle_button.dart';

enum IdeasView { notes, diagrams }

abstract class _IdeasContentActions {
  bool get isNotesView;
  Future<void> onPrimaryActionPressed();
  Future<void> onCreateNoteRequested();
  Future<void> onCreateFolderRequested();
}

class IdeasContentController {
  _IdeasContentActions? _actions;

  bool get isNotesView => _actions?.isNotesView ?? false;

  void _attach(_IdeasContentActions actions) {
    _actions = actions;
  }

  void _detach(_IdeasContentActions actions) {
    if (identical(_actions, actions)) {
      _actions = null;
    }
  }

  Future<void> onPrimaryActionPressed() async {
    await _actions?.onPrimaryActionPressed();
  }

  Future<void> onCreateNoteRequested() async {
    await _actions?.onCreateNoteRequested();
  }

  Future<void> onCreateFolderRequested() async {
    await _actions?.onCreateFolderRequested();
  }
}

class IdeasContent extends StatefulWidget {
  final IdeasContentController? controller;
  final String searchQuery;
  final ContentFilterState filterState;
  final ContentSortState sortState;

  const IdeasContent({
    super.key,
    this.controller,
    this.searchQuery = '',
    this.filterState = const ContentFilterState(),
    this.sortState = const ContentSortState(),
  });

  @override
  State<IdeasContent> createState() => IdeasContentState();
}

class IdeasContentState extends State<IdeasContent>
    implements _IdeasContentActions {
  IdeasView _activeView = IdeasView.notes;
  final NotesSubPageController _notesSubPageController =
      NotesSubPageController();

  @override
  bool get isNotesView => _activeView == IdeasView.notes;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant IdeasContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller?._detach(this);
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    super.dispose();
  }

  @override
  Future<void> onPrimaryActionPressed() async {
    if (_activeView != IdeasView.notes) return;
    await _notesSubPageController.onPrimaryActionPressed();
  }

  @override
  Future<void> onCreateNoteRequested() async {
    if (_activeView != IdeasView.notes) return;
    await _notesSubPageController.createNoteFromFab();
  }

  @override
  Future<void> onCreateFolderRequested() async {
    if (_activeView != IdeasView.notes) return;
    await _notesSubPageController.createFolderFromFab();
  }

  @override
  Widget build(BuildContext context) {
    final isNotes = _activeView == IdeasView.notes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: IdeasToggleButton(
                  label: "Notas",
                  isActive: isNotes,
                  onTap: () => setState(() => _activeView = IdeasView.notes),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: IdeasToggleButton(
                  label: "Diagramas",
                  isActive: !isNotes,
                  onTap: () => setState(() => _activeView = IdeasView.diagrams),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              isNotes ? "Notas recentes" : "Grupos de diagramas",
              key: ValueKey(_activeView),
              style: const TextStyle(
                color: Color(0xFF5D535A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) {
                final stackedChildren = <Widget>[...previousChildren];
                if (currentChild != null) {
                  stackedChildren.add(currentChild);
                }

                return Stack(
                  alignment: Alignment.topCenter,
                  children: stackedChildren,
                );
              },
              transitionBuilder: (child, animation) {
                final isIncoming = child.key == ValueKey(_activeView);
                final directionAwareAnimation = isIncoming
                    ? animation
                    : ReverseAnimation(animation);
                final curved = CurvedAnimation(
                  parent: directionAwareAnimation,
                  curve: Curves.easeOutCubic,
                );
                final offsetAnimation = Tween<double>(
                  begin: isIncoming ? 8.0 : 0.0,
                  end: isIncoming ? 0.0 : -8.0,
                ).animate(curved);
                final opacityAnimation = Tween<double>(
                  begin: isIncoming ? 0.0 : 1.0,
                  end: isIncoming ? 1.0 : 0.0,
                ).animate(curved);

                return AnimatedBuilder(
                  animation: curved,
                  child: child,
                  builder: (context, builtChild) {
                    return Opacity(
                      opacity: opacityAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, offsetAnimation.value),
                        child: builtChild,
                      ),
                    );
                  },
                );
              },
              child: _activeView == IdeasView.notes
                  ? NotesSubPage(
                      controller: _notesSubPageController,
                      searchQuery: widget.searchQuery,
                      filterState: widget.filterState,
                      sortState: widget.sortState,
                    )
                  : const DiagramsSubPage(key: ValueKey(IdeasView.diagrams)),
            ),
          ),
        ],
      ),
    );
  }
}
