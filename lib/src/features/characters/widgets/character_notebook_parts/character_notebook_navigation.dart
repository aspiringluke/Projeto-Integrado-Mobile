part of '../character_notebook_page.dart';

enum _TagKind { gender, sexuality, ethnicity, function }

enum _NotebookTab { geral, psique, historia, notas, design }

enum _NotebookSection { identidade, tags, medidas, narrativa, imagem }

enum _RelevanceEditorMode { simple, advanced }

const String _namePlaceholderText = characterNamePlaceholderText;
const String _aliasPlaceholderText = characterAliasPlaceholderText;
const String _mottoPlaceholderText = characterMottoPlaceholderText;
const String _formationsPlaceholderText =
    'Em que o personagem é formalmente formado e com o que o personagem formalmente trabalha.';
const String _titlesPlaceholderText =
    'Títulos formais e informais que designam o personagem.';

enum _CharacterColorTarget { cover, accent }

class _NotebookTabMeta {
  final String label;
  final IconData icon;

  const _NotebookTabMeta({required this.label, required this.icon});
}

class _PageStickyTabs extends StatelessWidget {
  final Color accentColor;
  final _NotebookTab activeTab;
  final Map<_NotebookTab, _NotebookTabMeta> tabs;
  final ValueChanged<_NotebookTab> onTabSelected;

  const _PageStickyTabs({
    required this.accentColor,
    required this.activeTab,
    required this.tabs,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.9),
            const Color(0xFFF3F0F3).withValues(alpha: 0.84),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.52)),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.045)),
        ),
      ),
      child: Row(
        children: [
          for (final entry in tabs.entries)
            Expanded(
              child: _PageStickyTabChip(
                label: entry.value.label,
                icon: entry.value.icon,
                accentColor: accentColor,
                selected: entry.key == activeTab,
                onTap: () => onTabSelected(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageStickyTabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  const _PageStickyTabChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.2),
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.34)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: selected ? 0.46 : 0.34),
                selected
                    ? accentColor.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 0,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: selected
                          ? _darkenCharacterDialogColor(accentColor, 0.22)
                          : const Color(0xFF544959),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? _darkenCharacterDialogColor(accentColor, 0.22)
                            : const Color(0xFF2C262C),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
