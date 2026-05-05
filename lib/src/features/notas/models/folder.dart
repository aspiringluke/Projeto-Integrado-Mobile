import 'dart:ui';

class Folder
{
    final String title;
    final int? id;
    final Color color;
    final int? parentFolderId;

    Folder({
        required this.title,
        required this.color,
        this.id,
        this.parentFolderId,
    });
}
