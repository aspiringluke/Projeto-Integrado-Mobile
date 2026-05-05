import 'dart:ui';

class Note
{
    final int? id;
    final String title;
    final String text;
    final Color color;
    final int? idPasta;

    Note({
        this.id,
        required this.title,
        required this.text,
        required this.color,
        this.idPasta
    });
}
