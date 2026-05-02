

abstract interface class INotaService
{
    bool createNewNote(String text);
    bool updateNote(int id);
    Object? getNote(int id);
    List<Object?> listNotes(); 
    bool deleteNote(int id);
}