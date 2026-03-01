// SaveSystem.cs
// TODO: Не завершено! Нужно доработать сериализацию.
// IDEA: Добавить поддержку JSON и бинарного формата.
// FIXME: Проблема с кодировкой при сохранении русских символов.

using System;
using System.IO;

public class SaveSystem
{
    // Singleton паттерн
    private static SaveSystem _instance;
    public static SaveSystem Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = new SaveSystem();
            }
            return _instance;
        }
    }
    
    // HACK: Временное решение для пути
    private string savePath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
    
    // WORKAROUND: Обход ошибки с длинными путями
    public void Save(string data)
    {
        // OPTIMIZE: Нужно кэшировать путь
        File.WriteAllText(savePath + "\\save.dat", data);
    }
    
    public string Load()
    {
        return File.ReadAllText(savePath + "\\save.dat");
    }
}
