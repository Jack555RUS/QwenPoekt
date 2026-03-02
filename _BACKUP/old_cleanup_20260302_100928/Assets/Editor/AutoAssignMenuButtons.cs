using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Автоматическое назначение кнопок в MainMenuController
    /// </summary>
    public class AutoAssignMenuButtons
    {
        [MenuItem("Tools/Drag Racing/Setup/Auto-Assign MainMenu Buttons")]
        public static void AutoAssign()
        {
            Debug.Log("=== НАЗНАЧЕНИЕ КНОПОК ===");
            
            string scenePath = "Assets/Scenes/MainMenu.unity";
            EditorSceneManager.OpenScene(scenePath);
            
            // Находим MainMenuController
            var controller = Object.FindObjectOfType<ProbMenu.Menus.MainMenuController>();
            if (controller == null)
            {
                Debug.LogError("❌ MainMenuController не найден!");
                return;
            }
            
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
                    case "NewGameButton": btnNewGame = btn; break;
                    case "ContinueButton": btnContinue = btn; break;
                    case "SaveButton": btnSave = btn; break;
                    case "LoadButton": btnLoad = btn; break;
                    case "SettingsButton": btnSettings = btn; break;
                    case "CancelButton": btnExit = btn; break;
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
            Debug.Log($"  btnNewGame: {(btnNewGame != null ? "OK" : "NULL")}");
            Debug.Log($"  btnContinue: {(btnContinue != null ? "OK" : "NULL")}");
            Debug.Log($"  btnSave: {(btnSave != null ? "OK" : "NULL")}");
            Debug.Log($"  btnLoad: {(btnLoad != null ? "OK" : "NULL")}");
            Debug.Log($"  btnSettings: {(btnSettings != null ? "OK" : "NULL")}");
            Debug.Log($"  btnExit: {(btnExit != null ? "OK" : "NULL")}");
            
            EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
            Debug.Log("✅ Сцена сохранена");
        }
    }
}
