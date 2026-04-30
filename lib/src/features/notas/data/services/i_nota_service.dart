

abstract interface class INotaService
{
    final int currentNoteId;
    final String currentNoteText = "";

    INotaService({required this.currentNoteId});
    bool createNewNote(String text);
    bool updateNote();
    bool getNote();
    bool deleteNote();
}