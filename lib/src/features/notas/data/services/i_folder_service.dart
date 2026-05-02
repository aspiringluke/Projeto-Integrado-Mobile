abstract interface class IFolderService
{
    bool createNewFolder(String title);
    bool updateFolder(int id);
    // TODO: Revisar esses tipos de retorno
    List<Object?> getFolder(int id);
    List<List<Object?>> listFolders(); 
    bool deleteFolder(int id);
}