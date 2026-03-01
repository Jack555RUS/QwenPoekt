// FileHelper.cs
// Utility класс для работы с файлами

using System;
using System.IO;
using System.Text;

public static class FileHelper
{
    // Extensions метод для безопасного чтения
    public static string ReadAllTextSafe(this string path, Encoding encoding = null)
    {
        encoding = encoding ?? Encoding.UTF8;
        
        if (File.Exists(path))
        {
            return File.ReadAllText(path, encoding);
        }
        
        return string.Empty;
    }
    
    // Helper метод для записи
    public static void WriteAllTextSafe(string path, string content, Encoding encoding = null)
    {
        encoding = encoding ?? Encoding.UTF8;
        
        string directory = Path.GetDirectoryName(path);
        
        if (!Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }
        
        File.WriteAllText(path, content, encoding);
    }
    
    // Tools для проверки файла
    public static bool FileExistsAndNotEmpty(string path)
    {
        if (!File.Exists(path))
        {
            return false;
        }
        
        var info = new FileInfo(path);
        return info.Length > 0;
    }
}
