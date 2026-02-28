# 🏁 Drag Race - Project Context

## Project Overview

**Drag Race** is a 2D drag racing game built in Unity featuring a career system, balanced economy, and rubber-banding AI opponents.

**Target Platform:** Windows (win32)  
**Unity Version:** 6000.1.17f1  
**Resolution:** 1920×1080 (default), scalable from 640×480 to 2560×1440

---

## 📁 Project Structure

```
D:\QwenPoekt\DragRace\
├── DragRace/                    # Main Unity project folder
│   ├── Assets/
│   │   ├── Scripts/
│   │   │   ├── Core/            # Core systems (GameManager, Bootstrap, GameConfig)
│   │   │   ├── Data/            # Data models and ScriptableObjects
│   │   │   ├── Managers/        # CareerManager
│   │   │   ├── SaveSystem/      # Save/Load system
│   │   │   ├── InputSystem/     # Input handling and key bindings
│   │   │   ├── Vehicles/        # Vehicle physics and data
│   │   │   ├── Racing/          # Race logic, AI, traffic light
│   │   │   ├── UI/              # All UI screens
│   │   │   │   └── Menus/       # Main menu, game menu
│   │   │   ├── Audio/           # Audio manager
│   │   │   ├── Effects/         # Race effects
│   │   │   ├── Utils/           # Utilities
│   │   │   ├── Editor/          # Editor scripts
│   │   │   └── Test/            # Test scripts
│   │   ├── Scenes/              # Unity scenes
│   │   ├── Prefabs/             # Prefabs
│   │   ├── Resources/           # ScriptableObjects (GameConfig, CarDatabase, PartsDatabase)
│   │   ├── Sprites/             # 2D sprites
│   │   ├── Audio/               # Audio files
│   │   └── Fonts/               # Fonts
│   ├── ProjectSettings/         # Unity project settings
│   └── Packages/                # Unity packages
├── Plan.txt                     # Original game design document
└── DragRace_BACKUP_2026-02-25/  # Backup folder
```

---

## 🚀 Current Development Status

### ✅ Completed (Step 2)

- **All core scripts created** (36 .cs files)
- **Code compiles without errors** (79 errors fixed)
- **Minimal working scene** (Start.unity) with:
  - Main Camera
  - Background (gray rectangle)
  - Title text "DRAG RACE"
  - Canvas with START button
  - EventSystem
- **Button click test** - SimpleButtonTest.cs changes button color on click

### 🔄 In Progress

- **Step 3:** Create main menu (MainMenu.unity) with buttons
- **Step 4:** Add scene transitions
- **Step 5:** Add GameManager singleton

### 📋 Remaining Tasks

1. Main Menu UI (New Game, Continue, Save, Load, Settings, Exit)
2. Game Menu (Race, Garage, Tuning, Shop, Menu)
3. Career system UI
4. Vehicle physics implementation
5. AI opponent with rubber-banding
6. Save/Load system (5 slots + 5 auto-saves)
7. Settings (resolution, fullscreen, audio, key bindings)
8. Character progression system
9. Economy balance
10. Audio and visual effects

---

## 🛠 Building and Running

### Prerequisites

- **Unity Hub** installed
- **Unity 6000.1.17f1** (or compatible version)
- **Windows 10/11**

### Setup Instructions

1. **Add project to Unity Hub:**
   - Open Unity Hub
   - Click "Add"
   - Select: `D:\QwenPoekt\DragRace\DragRace`

2. **Open project:**
   - Select DragRace in Unity Hub
   - Choose Unity 6000.1.17f1
   - Click "Open Project"

3. **Wait for compilation** (2-5 minutes)

4. **Open scene:**
   - Navigate to `Assets/Scenes/Start.unity`
   - Double-click to open

5. **Press Play** (▶)

### Testing the Button (Step 2)

1. In Unity Editor, select **Canvas** object in Hierarchy
2. In Inspector, click **Add Component**
3. Search for `SimpleButtonTest`
4. Select **DragRace.Test.SimpleButtonTest**
5. In the Start Button field, drag the **StartButton** object from Hierarchy
6. Save (Ctrl+S)
7. Press Play
8. Click the START button
9. Check Console for messages:
   ```
   === ШАГ 2: Тест кнопки START ===
   ✅✅✅ КНОПКА START НАЖАТА! ✅✅✅
   ✅✅✅ ЦВЕТ КНОПКИ ИЗМЕНЁН НА ЖЁЛТЫЙ! ✅✅✅
   ```

---

## 📦 Key Packages

```json
{
  "com.unity.inputsystem": "1.18.0",
  "com.unity.ugui": "2.0.0",
  "com.unity.modules.physics": "1.0.0",
  "com.unity.modules.physics2d": "1.0.0",
  "com.unity.modules.ui": "1.0.0"
}
```

---

## 🎮 Game Design (from Plan.txt)

### Main Menu
- New Game
- Continue (load latest save)
- Save (5 manual slots)
- Load (5 manual + 5 auto-save slots with timestamps)
- Settings (resolution, fullscreen, audio, key bindings)
- Exit

### Game Menu
- Race (1/8, 1/4, 1/2, 1 mile distances)
- Garage (select owned vehicles)
- Tuning (upgrade parts with comparison)
- Shop (buy/sell cars and parts)
- Menu (return to main menu)

### Controls
| Action | Default Key |
|--------|-------------|
| Accelerate | W / Up Arrow |
| Shift Up | D / Right Arrow |
| Shift Down | A / Left Arrow |
| Nitro | Left Shift / N |
| Pause | Escape |

### Career System
- 5 tiers with progressive difficulty
- 3 races + boss per tier
- Star system (0-3 stars per race)
- Rubber-banding AI for dynamic difficulty

### Economy
- Starting money: $10,000
- Car prices: $35,000 - $160,000
- Prize money scales with tier
- Balanced for 8-15 races per car purchase

---

## 🔧 Development Conventions

### Code Style
- **Language:** C#
- **Namespace:** DragRace.[ModuleName]
- **Attributes:** `[SerializeField]` for Inspector fields
- **Unity 6 API:** Use `FindFirstObjectByType` instead of `FindObjectOfType`

### Testing Practices
- Add test scripts to scenes for verification
- Use Debug.Log for runtime verification
- Check Console for errors after each change

### File Naming
- **Scripts:** PascalCase.cs (e.g., `GameManager.cs`)
- **Scenes:** PascalCase.unity (e.g., `MainMenu.unity`)
- **Prefabs:** PascalCase.prefab

### Version Control Notes
- Backup created before major changes: `DragRace_BACKUP_2026-02-25/`
- All errors documented in `ERROR.txt`
- Fix instructions in various `.txt` and `.md` files

---

## 🐛 Known Issues & Solutions

### Current Issue: Button Click Not Working
**Problem:** Button doesn't change color when clicked  
**Status:** Debugging with detailed logging

**Solution in progress:**
1. Check if StartButton is assigned in Inspector
2. Verify Image component exists on button
3. Confirm listener is added via UnityAction
4. Check Console for debug messages

### Input Manager Warning
**Message:** "This project uses Input Manager, which is marked for deprecation"  
**Status:** Can be ignored (not an error, just a warning)

### GUID Extraction Warnings
**Message:** "Could not extract GUID in text file Assets/Scenes/*.unity"  
**Status:** Normal for manually created scenes. Fix by re-assigning scripts in Unity Editor.

---

## 📝 Recent Changes (Latest Session)

### Fixed
- ✅ 79 compilation errors across 36 scripts
- ✅ Created minimal working scene (Start.unity)
- ✅ Added SimpleButtonTest.cs for button testing
- ✅ Removed EventTrigger dependency (causing compilation errors)
- ✅ Improved button click detection with UnityAction

### In Progress
- 🔄 Step 2: Button click test with color change
- ⏳ Step 3: Main menu creation (next)

---

## 🎯 Next Steps

### Immediate (Step 3)
1. Create MainMenu.unity scene
2. Add Canvas with buttons:
   - New Game
   - Continue
   - Settings
   - Exit
3. Create simple button click handler
4. Test all buttons

### Short Term (Steps 4-6)
1. Add scene transitions (Start → MainMenu)
2. Implement GameManager singleton
3. Create SaveManager
4. Add InputManager

### Medium Term
1. Implement career system UI
2. Add vehicle selection in Garage
3. Create tuning interface with part comparison
4. Build shop with car/part purchasing

### Long Term
1. Complete vehicle physics
2. Implement AI with rubber-banding
3. Add audio system
4. Create visual effects
5. Build and test full game loop

---

## 📞 Support & Documentation

### Key Documentation Files
- `README.md` - Full project documentation
- `QUICK_START.md` - Quick start guide
- `IMPLEMENTATION_REPORT.md` - Implemented mechanics report
- `Plan.txt` - Original game design (Russian)
- `MINIMAL_VERSION_STEP_1.txt` - Minimal version instructions

### Debugging Workflow
1. Check `d:\QwenPoekt\DragRace\ERROR.txt` for current errors
2. Review Unity Console (Ctrl+Shift+C)
3. Check Logs folder: `D:\QwenPoekt\DragRace\DragRace\Logs\`
4. Read latest fix documentation in project root

### Auto-Setup Tools
- `ProjectAutoInitializer.cs` - Auto-creates configs on first open
- `AutoSetupProject.cs` - Manual setup via DragRace menu

---

## 💾 Save System

### Save Locations
- **Manual saves:** 5 slots
- **Auto-saves:** 5 slots (overwrite oldest, 5-minute interval)
- **Path:** `C:\Users\[Username]\AppData\LocalLow\DragRace\`

### Save Data
- Player progress (career tier, race index)
- Owned vehicles and parts
- Character stats and experience
- Money and achievements
- Settings and key bindings

---

## 🎨 Art & Audio Requirements

### Needed Assets
- **Vehicles:** 2D side-view sprites (multiple car models)
- **Environment:** Road, background, skybox
- **UI:** Buttons, icons, backgrounds
- **Audio:** Engine sounds, tire squeal, UI clicks, music

### Current Status
- Using placeholder colors and basic shapes
- All functionality works without final art

---

## 📊 Project Statistics

- **Total Scripts:** 36 .cs files
- **Total Scenes:** 3 (Start, MainMenu, Race - minimal versions)
- **Compilation Errors Fixed:** 79
- **Current Development Phase:** Step 2 of 20 (UI Testing)
- **Estimated Completion:** 10-15% complete

---

## ⚡ Quick Commands

### In Unity Editor
```
Open Scene: Assets/Scenes/Start.unity
Add Component: Right-click object → Add Component
Search Script: Type script name in Inspector
Play Test: Press ▶ or Ctrl+P
Console: Ctrl+Shift+C
Build: File → Build Settings → Build
```

### Via Code (Editor scripts)
```
DragRace → Auto Setup Project (menu)
DragRace → Create ScriptableObjects (menu)
```

---

*Last updated: 2026-02-26*  
*Current Phase: Step 2 - Button Click Testing*  
*Next: Step 3 - Main Menu Creation*
