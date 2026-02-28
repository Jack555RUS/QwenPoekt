# Racing Game - Menu Build Instructions

## Quick Start

### Option 1: Test in Unity Editor
```cmd
QuickTest.bat
```
This opens Unity Editor. Then:
1. Open `Assets/Scenes/MainMenu.unity`
2. Press Play (▶️)
3. Test the menu

### Option 2: Build EXE
```cmd
BuildAndRun.bat
```
This will:
1. Build the game
2. Create `Build/RacingGame.exe`
3. Ask if you want to run it

### Option 3: PowerShell
```powershell
.\build.ps1 -BuildOnly
```

---

## Files

| File | Description |
|------|-------------|
| `BuildAndRun.bat` | Build and run game |
| `QuickTest.bat` | Open Unity for testing |
| `build.ps1` | PowerShell build script |
| `MENU_BUILD.md` | Full documentation (Russian) |
| `FINAL_MENU_REPORT.md` | Complete report (Russian) |

---

## Requirements

- Unity 6000.3.10f1
- Windows 10/11 (x64)

---

## Troubleshooting

### Build fails
Check `Build/Build.log` for errors.

### Unity not found
Edit `BuildAndRun.bat` and update `UNITY_PATH`.

### Missing scenes
In Unity: File → Build Settings → Add all scenes from `Assets/Scenes/`

---

## Menu Features

### Main Menu
- New Game
- Continue
- Save
- Load
- Settings
- Exit

### Settings Menu
- Music Volume (Slider)
- SFX Volume (Slider)
- Resolution (Dropdown)
- Fullscreen (Toggle)
- Quality (Dropdown)

### Game Menu
- Race
- Garage
- Tuning
- Shop
- Menu (back to main)

### Pause Menu
- Resume
- Main Menu
- Settings
- Exit

---

For detailed documentation, see `MENU_BUILD.md`.
