import 'package:flutter/material.dart';

import '../../features/diagrams/pages/diagrams_sub_page.dart';
import '../../features/notas/pages/notes_sub_page.dart';
import '../../shared/widgets/buttons/ideas_toggle_button.dart';

enum IdeasView { notes, diagrams }

class IdeasContent extends StatefulWidget {
  const IdeasContent({super.key});

  @override
  State<IdeasContent> createState() => IdeasContentState();
}

class IdeasContentState extends State<IdeasContent> {
  IdeasView _activeView = IdeasView.notes;
  final GlobalKey<NotesSubPageState> _notesSubPageKey =
      GlobalKey<NotesSubPageState>();

  Future<void> onPrimaryActionPressed() async {
    if (_activeView != IdeasView.notes) return;
    await _notesSubPageKey.currentState?.onPrimaryActionPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isNotes = _activeView == IdeasView.notes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                ...previousChildren,
                ?currentChild,
              ],
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
                  key: _notesSubPageKey,
                )
              : const DiagramsSubPage(key: ValueKey(IdeasView.diagrams)),
        ),
      ],
    );
  }
}
