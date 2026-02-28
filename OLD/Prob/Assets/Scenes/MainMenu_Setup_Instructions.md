# Инструкция по настройке сцены MainMenu

## Шаг 1: Открыть сцену MainMenu
1. В Unity Editor откройте `Assets/Scenes/MainMenu.unity`

## Шаг 2: Создать GameObject для инициализации
1. В иерархии создайте пустой GameObject: **Right-click → Create Empty**
2. Назовите его **MenuInitializer**
3. Добавьте компонент **MainMenuInitializer**:
   - В инспекторе нажмите **Add Component**
   - Найдите `MainMenuInitializer`
   - Перетащите `Assets/UI Toolkit/MainMenu.uxml` в поле **Main Menu Asset**
   - Перетащите `Assets/UI Toolkit/SettingsMenu.uxml` в поле **Settings Menu Asset**
   - Перетащите `Assets/AudioMixer.mixer` в поле **Audio Mixer**

## Шаг 3: Настроить Main Camera
1. Выберите объект **Main Camera**
2. В компоненте Camera установите:
   - **Clear Flags**: Solid Color
   - **Background**: Темно-серый цвет (например, RGB: 0.1, 0.1, 0.1)
   - **Projection**: Orthographic (для UI)

## Шаг 4: Проверить Build Settings
1. Откройте **File → Build Settings**
2. Убедитесь, что сцена `MainMenu` добавлена в список сцен
3. Убедитесь, что сцена `MainMenu` стоит первой в списке (индекс 0)

## Шаг 5: Настроить Player Settings
1. В **Build Settings** нажмите **Player Settings**
2. В разделе **Resolution and Presentation**:
   - **Default Screen Width**: 800
   - **Default Screen Height**: 600
   - **Fullscreen Mode**: Windowed
   - **Run In Background**: ✓

## Шаг 6: Настроить Quality Settings
1. Откройте **Edit → Project Settings → Quality**
2. Проверьте уровни качества:
   - **Level 0**: Low
   - **Level 1**: Medium
   - **Level 2**: High
   - **Level 3**: Ultra

## Шаг 7: Проверить Input Settings
1. Откройте **Edit → Project Settings → Input**
2. Убедитесь, что оси настроены:
   - **Horizontal**: A/D, Left/Right
   - **Vertical**: W/S, Up/Down
   - **Fire1**: Left Ctrl, Mouse 0
   - **Jump**: Space
   - **Submit**: Return, Keypad Enter
   - **Cancel**: Escape

## Шаг 8: Тестирование
1. Нажмите **Play** в Unity Editor
2. Проверьте:
   - ✅ Отображается главное меню с кнопками
   - ✅ Кнопка "Настройки" открывает меню настроек
   - ✅ Кнопка "Назад" возвращает в главное меню
   - ✅ Ползунки громкости работают
   - ✅ Переключатель Fullscreen работает
   - ✅ Dropdown разрешения экрана заполняется
   - ✅ Dropdown качества графики работает
   - ✅ Кнопка "Выход" закрывает игру (в билде)

## Возможные проблемы и решения

### Проблема: UI не отображается
**Решение**: Убедитесь, что Canvas/UIDocument настроен правильно и имеет правильный Render Mode

### Проблема: Кнопки не нажимаются
**Решение**: Проверьте, что Image компонент на кнопках имеет правильный цвет и не прозрачный

### Проблема: Настройки не сохраняются
**Решение**: Проверьте, что AudioManager подключен и AudioMixer настроен

### Проблема: Разрешения не меняются
**Решение**: В режиме Editor некоторые разрешения могут не работать корректно. Проверьте в билде.
