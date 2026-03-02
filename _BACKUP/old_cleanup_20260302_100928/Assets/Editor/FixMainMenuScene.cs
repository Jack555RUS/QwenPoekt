using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Исправление сцены MainMenu - назначение кнопок
    /// Запустить: Tools → Drag Racing → Fix → Fix MainMenu Scene
    /// </summary>
    public class FixMainMenuScene
    {
        [MenuItem("Tools/Drag Racing/Fix/Fix MainMenu Scene")]
        public static void FixScene()
        {
            Debug.Log("=== ИСПРАВЛЕНИЕ СЦЕНЫ MAIN MENU ===");
            
            string scenePath = "Assets/Scenes/MainMenu.unity";
            EditorSceneManager.OpenScene(scenePath);
            
            // Находим MainMenuController
            var controller = Object.FindObjectOfType<ProbMenu.Menus.MainMenuController>();
            if (controller == null)
            {
                Debug.LogError("❌ MainMenuController не найден!");
                return;
            }
            
            Debug.Log($"✅ Найден MainMenuController: {controller.name}");
            
            // Находим кнопки по именам
            Button[] allButtons = Object.FindObjectsOfType<Button>();
            
            Button btnNewGame = null;
            Button btnContinue = null;
            Button btnSave = null;
            Button btnLoad = null;
            Button btnSettings = null;
            Button btnExit = null;
            
            foreach (var btn in allButtons)
            {
                Debug.Log($"  Найдено: {btn.name}");
                
                switch (btn.name)
                {
                    case "NewGameButton":
                        btnNewGame = btn;
                        break;
                    case "ContinueButton":
                        btnContinue = btn;
                        break;
                    case "SaveButton":
                        btnSave = btn;
                        break;
                    case "LoadButton":
                        btnLoad = btn;
                        break;
                    case "SettingsButton":
                        btnSettings = btn;
                        break;
                    case "CancelButton":
                    case "ExitButton":
                    case "ButtonExit":
                        btnExit = btn;
                        Debug.Log($"  ✅ ВЫХОД: {btn.name}");
                        break;
                }
            }
            
            // Назначаем через SerializedObject
            SerializedObject so = new SerializedObject(controller);
            
            so.FindProperty("btnNewGame").objectReferenceValue = btnNewGame;
            so.FindProperty("btnContinue").objectReferenceValue = btnContinue;
            so.FindProperty("btnSave").objectReferenceValue = btnSave;
            so.FindProperty("btnLoad").objectReferenceValue = btnLoad;
            so.FindProperty("btnSettings").objectReferenceValue = btnSettings;
            so.FindProperty("btnExit").objectReferenceValue = btnExit;
            
            so.ApplyModifiedProperties();
            
            Debug.Log("✅ Кнопки назначены!");
            Debug.Log($"  btnNewGame: {(btnNewGame != null ? "✅" : "❌")}");
            Debug.Log($"  btnContinue: {(btnContinue != null ? "✅" : "❌")}");
            Debug.Log($"  btnSave: {(btnSave != null ? "✅" : "❌")}");
            Debug.Log($"  btnLoad: {(btnLoad != null ? "✅" : "❌")}");
            Debug.Log($"  btnSettings: {(btnSettings != null ? "✅" : "❌")}");
            Debug.Log($"  btnExit: {(btnExit != null ? "✅" : "❌")}");
            
            // Сохраняем сцену
            EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
            Debug.Log("✅ Сцена сохранена!");
            
            Debug.Log("=== ИСПРАВЛЕНИЕ ЗАВЕРШЕНО ===");
            Debug.Log("Теперь пересоберите проект!");
        }
    }
}
