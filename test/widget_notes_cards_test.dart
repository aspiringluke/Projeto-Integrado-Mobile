import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado_mobile/src/app/widgets/custom_nav_bar.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_list_card.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/note_list_card.dart';

void main() {
  testWidgets('NoteListCard shows title and preview text', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteListCard(
            title: 'Nota de teste',
            text: 'Esse é um conteúdo de teste para nota.',
            highlightColor: Colors.orange,
            metadata: const NoteMetadata(
              tagGroups: [],
              linkTarget: NoteLinkTarget(),
            ),
            createdAt: DateTime(2025, 1, 1),
            lastModified: DateTime(2025, 1, 2),
            lastAccessed: DateTime(2025, 1, 3),
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Nota de teste'), findsOneWidget);
    expect(find.textContaining('Esse é um conteúdo de teste'), findsOneWidget);

    await tester.tap(find.text('Nota de teste'));
    expect(tapped, isTrue);
  });

  testWidgets('FolderListCard shows folder title and note count', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FolderListCard(
            folder: Folder(
              title: 'Pasta de teste',
              color: Colors.blue,
              createdAt: DateTime(2025, 1, 1),
              lastModified: DateTime(2025, 1, 2),
              lastAccessed: DateTime(2025, 1, 3),
            ),
            folderStats: ContentStats.fromText('Apenas uma nota de exemplo.'),
            noteCount: 4,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Pasta de teste'), findsOneWidget);
    expect(find.text('4 nota(s)'), findsOneWidget);

    await tester.tap(find.text('Pasta de teste'));
    expect(tapped, isTrue);
  });

  testWidgets('CustomNavBar toggles between tabs', (tester) async {
    var activeTab = NavTab.projects;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return CustomNavBar(
              activeTab: activeTab,
              onTabSelected: (selectedTab) {
                setState(() {
                  activeTab = selectedTab;
                });
              },
            );
          },
        ),
      ),
    );

    expect(find.text('Ideias'), findsOneWidget);
    await tester.tap(find.text('Ideias'));
    await tester.pumpAndSettle();
    expect(activeTab, NavTab.ideas);
  });
}
