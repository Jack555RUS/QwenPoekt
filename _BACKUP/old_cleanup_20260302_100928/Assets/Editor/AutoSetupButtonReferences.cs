using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Автоматическая настройка ссылок на кнопки в контроллерах
    /// </summary>
    public class AutoSetupButtonReferences
    {
        [MenuItem("Tools/Drag Racing/Setup/Auto-Assign Button References")]
        public static void AutoAssignAllButtons()
        {
            Debug.Log("=== АВТОМАТИЧЕСКАЯ НАСТРОЙКА КНОПОК ===");
            
            SetupMainMenuButtons();
            SetupGameMenuButtons();
            
            Debug.Log("=== ГОТОВО! ===");
            Debug.Log("Проверьте ссылки в инспекторе и сохраните сцены!");
        }

        [MenuItem("Tools/Drag Racing/Setup/Setup MainMenu Buttons")]
        public static void SetupMainMenuButtons()
        {
            Debug.Log("🔧 Настройка MainMenu...");
            
            string scenePath = "Assets/Scenes/MainMenu.unity";
            EditorSceneManager.OpenScene(scenePath);
            
            // Находим MainMenuController
            var controller = Object.FindObjectOfType<ProbMenu.Menus.MainMenuController>();
            if (controller == null)
            {
                Debug.LogError("❌ MainMenuController не найден!");
                return;
            }
            
            // Находим все кнопки в сцене
            Button[] allButtons = Object.FindObjectsOfType<Button>();
            Debug.Log($"Найдено кнопок: {allButtons.Length}");
            
            for (int i = 0; i < allButtons.Length; i++)
            {
                Debug.Log($"  [{i}] {allButtons[i].name}");
            }
            
            // Сортируем по именам
            System.Array.Sort(allButtons, (a, b) => string.Compare(a.name, b.name));
            
            // Назначаем в инспекторе
            SerializedObject so = new SerializedObject(controller);
            SerializedProperty buttonsProp = so.FindProperty("menuButtons");
            
            if (buttonsProp != null)
            {
                buttonsProp.ClearArray();
                
                for (int i = 0; i < Mathf.Min(6, allButtons.Length); i++)
                {
                    buttonsProp.InsertArrayElementAtIndex(i);
                    buttonsProp.GetArrayElementAtIndex(i).objectReferenceValue = allButtons[i];
                    Debug.Log($"✅ Назначена кнопка {i}: {allButtons[i].name}");
                }
                
                so.ApplyModifiedProperties();
            }
            
            // Сохраняем
            EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
            Debug.Log("✅ MainMenu настроен!");
        }

        [MenuItem("Tools/Drag Racing/Setup/Setup GameMenu Buttons")]
        public static void SetupGameMenuButtons()
        {
            Debug.Log("🔧 Настройка GameMenu...");
            
            string scenePath = "Assets/Scenes/GameMenu.unity";
            EditorSceneManager.OpenScene(scenePath);
            
            // Находим GameMenuController
            var controller = Object.FindObjectOfType<ProbMenu.Menus.GameMenuController>();
            if (controller == null)
            {
                Debug.LogError("❌ GameMenuController не найден!");
                return;
            }
            
            // Находим все кнопки
            Button[] allButtons = Object.FindObjectsOfType<Button>();
            Debug.Log($"Найдено кнопок: {allButtons.Length}");
            
            // Назначаем
            SerializedObject so = new SerializedObject(controller);
            SerializedProperty buttonsProp = so.FindProperty("gameMenuButtons");
            
            if (buttonsProp != null)
            {
                buttonsProp.ClearArray();
                
                for (int i = 0; i < Mathf.Min(5, allButtons.Length); i++)
                {
                    buttonsProp.InsertArrayElementAtIndex(i);
                    buttonsProp.GetArrayElementAtIndex(i).objectReferenceValue = allButtons[i];
                    Debug.Log($"✅ Назначена кнопка {i}: {allButtons[i].name}");
                }
                
                so.ApplyModifiedProperties();
            }
            
            EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
            Debug.Log("✅ GameMenu настроен!");
        }
    }
}
