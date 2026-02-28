---
status: stable
created: 2026-03-01
last_reviewed: 2026-03-01
book_title: Unity 6 Shaders and Effects Cookbook
author: John P. Doran
---

# 📚 Unity 6 Shaders and Effects Cookbook — КОНСПЕКТ

**Оригинал:** Unity 6 Shaders and Effects Cookbook: Over 50 Recipes for Creating Captivating Visual Effects in Unity and Enhancing Your Game's Visual Impact, Fifth Edition
**Издатель:** Packt Publishing
**Дата:** Июль 2025
**Файл:** [`BOOK/URP_cookbook_shaders_and_visual_effects_Unity_6_final.pdf`](../BOOK/URP_cookbook_shaders_and_visual_effects_Unity_6_final.pdf)
**Страниц:** 532
**ISBN:** 9781835468579

---

## 📖 Содержание

1. [Часть I: Основы затенения и рендеринга в Unity](#часть-i-основы-затенения-и-рендеринга-в-unity)
2. [Часть II: Продвинутые шейдерные эффекты и манипуляция геометрией](#часть-ii-продвинутые-шейдерные-эффекты-и-манипуляция-геометрией)
3. [Часть III: Оптимизация производительности и полноэкранные эффекты](#часть-iii-оптимизация-производительности-и-полноэкранные-эффекты)
4. [Часть IV: Пользовательское освещение и продвинутое программирование шейдеров](#часть-iv-пользовательское-освещение-и-продвинутое-программирование-шейдеров)
5. [Ключевые темы](#ключевые-темы)
6. [Примеры кода](#примеры-кода)
7. [Лучшие практики](#лучшие-практики)
8. [Лучшие практики для DragRaceUnity](#лучшие-практики-для-dragraceunity)

---

## Часть I: Основы затенения и рендеринга в Unity

### Глава 1: Использование постобработки с URP

**Технические требования:** Unity Editor 6000.0.4f1, Universal 3D Core template

#### 1.1 Настройка постобработки (стр. 15-20)

**Как выполнить:**
1. Создать Volume Profile: `Assets → Create → Volume Profile`
2. Добавить Global Volume на сцену
3. Настроить Post-processing эффекты в профиле

**Ключевые эффекты:**
- **Bloom** — свечение ярких участков
- **Motion Blur** — размытие в движении
- **Depth of Field** — глубина резкости
- **Color Adjustments** — цветокоррекция
- **Vignette** — виньетирование
- **Film Grain** — зернистость плёнки

**Применение для гоночной игры:**
- Motion Blur для ощущения скорости (интенсивность 0.5-0.8)
- Bloom для фар и неоновых огней (threshold 0.8, intensity 1.5)
- Color Grading для создания атмосферы (тёплые тона для заката)

---

#### 1.2 Кинематографичный вид: зернистость, виньетирование, глубина резкости (стр. 21-28)

**Примеры из игр:**
- **Red Dead Redemption 2** — зернистость + виньетирование
- **The Last of Us Part II** — глубина резкости в катсценах
- **Resident Evil Village** — комбинация всех эффектов для хоррор-атмосферы

**Настройки для DragRaceUnity:**

| Эффект | Настройка | Значение |
|--------|-----------|----------|
| Film Grain | Intensity | 0.05-0.1 |
| Vignette | Intensity | 0.2-0.3 |
| Vignette | Roundness | 0.5 |
| Depth of Field | Mode | Bokeh |
| Depth of Field | Aperture | f/2.8-f/5.6 |

**Shader Graph узлы для виньетирования:**
```
Position (Center) → Distance → Smoothstep → Multiply с цветом
```

---

#### 1.3 Bloom и Motion Blur (стр. 29-36)

**Примеры из игр:**
- **Cyberpunk 2077** — интенсивный bloom для неоновых огней
- **Final Fantasy XV** — кинематографичный motion blur

**Настройки Bloom для гоночной игры:**

```
Bloom Settings:
- Threshold: 0.8 (яркие участки)
- Intensity: 1.5-2.0
- Scatter: 0.7
- Clamp: 65472
- Tint: (1, 1, 1) или цвет неона
- Dirt Texture: опционально для линз
```

**Настройки Motion Blur:**

```
Motion Blur Settings:
- Mode: Camera + Objects
- Intensity: 0.5-0.85 (для высокой скорости)
- Clamp: 0.05
- Sample Count: Medium (8-12 samples)
```

**Важно:** Для гоночной игры motion blur критичен для ощущения скорости 200+ км/ч

---

#### 1.4 Цветокоррекция (Color Grading) (стр. 37-44)

**Пример из The Matrix** — зелёный оттенок для матрицы

**Рецепты для разных атмосфер:**

| Атмосфера | Lift | Gamma | Gain |
|-----------|------|-------|------|
| **Закат** | (0.95, 0.85, 0.7) | (1.0, 0.95, 0.9) | (1.1, 0.9, 0.7) |
| **Ночь** | (0.8, 0.85, 1.0) | (0.9, 0.95, 1.05) | (0.85, 0.9, 1.1) |
| **Дождь** | (0.85, 0.9, 0.95) | (0.95, 0.98, 1.0) | (0.9, 0.95, 1.05) |
| **Пустыня** | (1.0, 0.9, 0.75) | (1.05, 1.0, 0.9) | (1.15, 1.0, 0.8) |

**Применение:**
- Создать несколько Volume Profiles для разных трасс
- Переключать через скрипт при смене уровня

---

#### 1.5 Туман для хоррор-атмосферы (стр. 45-50)

**Настройки URP Fog:**

```
URP Asset → Fog:
- Enabled: true
- Color: (0.1, 0.1, 0.15) для ночного тумана
- Density: 0.02-0.05
- Start Distance: 10
- End Distance: 100
```

**Для гоночной игры:**
- Использовать для туманных трасс (горы, лес)
- Density 0.01-0.02 для лёгкой дымки
- Color matching skybox для естественности

---

### Глава 2: Создание вашего первого шейдера с Shader Graph

#### 2.1 Реализация простого Shader Graph (стр. 55-62)

**Базовая структура Shader Graph:**

```
Master Stack:
├── PBR Master (или Unlit)
│   ├── Albedo (цвет/текстура)
│   ├── Normal (нормаль)
│   ├── Metallic (металличность)
│   ├── Smoothness (гладкость)
│   ├── Emission (свечение)
│   └── Alpha (прозрачность)
```

**Первый шейдер — цветной куб:**
1. Create → Shader Graph → PBR Graph
2. Добавить узел Color
3. Подключить к Albedo
4. Save Asset → назначить на объект

---

#### 2.2 Добавление свойств к шейдеру (стр. 63-70)

**Создание свойств в Blackboard:**

| Property Type | Use Case | Пример |
|---------------|----------|--------|
| **Color** | Цвет материала | _BaseColor |
| **Vector1** | Числовые параметры | _Metallic, _Smoothness |
| **Texture2D** | Текстуры | _MainTex, _NormalMap |
| **Boolean** | Переключатели | _EnableEmission |

**Пример свойств для гоночного автомобиля:**

```
Blackboard Properties:
- _BaseColor (Color) = (1, 0, 0, 1) — цвет кузова
- _Metallic (Vector1) = 0.8 — металличность
- _Smoothness (Vector1) = 0.7 — гладкость
- _DecalTex (Texture2D) — логотипы спонсоров
- _EmissionColor (Color) = (0, 1, 1, 1) — цвет неона
- _EmissionIntensity (Vector1) = 2.0 — интенсивность свечения
```

---

#### 2.3 Использование свойств в Surface Shader (стр. 71-78)

**Shader Graph узлы для PBR:**

```
Sample Texture 2D (_MainTex)
    ↓
Multiply с _BaseColor
    ↓
PBR Master → Albedo

Texture 2D Asset (_NormalMap)
    ↓
Normal Unpack
    ↓
PBR Master → Normal

_Metallic (Vector1) → PBR Master → Metallic
_Smoothness (Vector1) → PBR Master → Smoothness
```

---

### Глава 3: Работа с поверхностями

#### 3.1 Реализация диффузного затенения (стр. 83-88)

**HLSL код для кастомного diffuse:**

```hlsl
Shader "Custom/BasicDiffuse" {
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _MainTex;
        fixed4 _Color;
        
        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
```

---

#### 3.2 Доступ и модификация упакованных массивов (стр. 89-94)

**Упаковка данных в RGBA каналы:**

```hlsl
// Упаковка 4 значений в один纹理
// R канал — данные A
// G канал — данные B
// B канал — данные C
// A канал — данные D

float4 packedData = tex2D(_PackedTexture, uv);
float valueA = packedData.r;
float valueB = packedData.g;
float valueC = packedData.b;
float valueD = packedData.a;
```

**Применение для terrain blending:**
- R: смешивание трава/земля
- G: смешивание камень/песок
- B: влажность поверхности
- A: высота снега

---

#### 3.3 Создание шейдера с нормал-маппингом (стр. 95-102)

**HLSL код нормал-маппинга:**

```hlsl
Shader "Custom/NormalMapping" {
    Properties {
        _MainTint ("Diffuse Tint", Color) = (1,1,1,1)
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _NormalIntensity ("Normal Map Intensity", Range(0,2)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert
        
        float4 _MainTint;
        sampler2D _NormalTex;
        float _NormalIntensity;
        
        struct Input {
            float2 uv_NormalTex;
        };
        
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Распаковка нормали из текстуры
            float3 normalMap = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
            
            // Усиление интенсивности
            normalMap = float3(
                normalMap.x * _NormalIntensity,
                normalMap.y * _NormalIntensity,
                normalMap.z
            );
            
            o.Normal = normalMap;
            o.Albedo = _MainTint.rgb;
            o.Alpha = _MainTint.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
```

**Для гоночной игры:**
- Нормал-мапы для кузова автомобиля (детали панелей)
- Нормал-мапы для асфальта (неровности дороги)
- Нормал-мапы для интерьера (текстура кожи, пластика)

---

#### 3.4 Создание голографического шейдера (стр. 103-110)

**Эффект для UI гоночной игры (меню, HUD):**

```hlsl
Shader "Custom/Holographic" {
    Properties {
        _MainColor ("Holo Color", Color) = (0, 1, 1, 1)
        _ScrollSpeed ("Scroll Speed", Range(0, 1)) = 0.1
        _ScanLineSpeed ("Scan Line Speed", Range(0, 2)) = 0.5
        _Intensity ("Intensity", Range(0, 2)) = 1.5
    }
    SubShader {
        Tags { 
            "Queue"="Transparent" 
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalPipeline"
        }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Attributes {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainColor;
                float _ScrollSpeed;
                float _ScanLineSpeed;
                float _Intensity;
            CBUFFER_END
            
            Varyings vert(Attributes input) {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }
            
            float4 frag(Varyings input) : SV_Target {
                // Горизонтальные сканирующие линии
                float scanLine = sin(input.uv.y * 100 - _Time.y * _ScanLineSpeed);
                scanLine = smoothstep(0, 0.2, scanLine);
                
                // Вертикальное скроллирование
                float2 scrollUV = input.uv;
                scrollUV.y += _Time.y * _ScrollSpeed;
                
                // Комбинирование эффектов
                float holo = scanLine * _Intensity;
                
                return float4(_MainColor.rgb, holo * _MainColor.a);
            }
            ENDHLSL
        }
    }
}
```

**Применение:**
- HUD элементы (спидометр, тахометр)
- Меню паузы
- Эффекты нитро-ускорения

---

### Глава 4: Работа с текстурным маппингом

#### 4.1 Добавление текстуры к шейдеру (стр. 115-120)

**Базовый код текстурирования:**

```hlsl
Properties {
    _MainTex ("Base Texture", 2D) = "white" {}
    _Tiling ("Tiling", Vector) = (1, 1, 0, 0)
}

// В fragment shader:
float2 tiledUV = IN.uv * _Tiling.xy + _Tiling.zw;
float4 texColor = tex2D(_MainTex, tiledUV);
```

---

#### 4.2 Прокрутка текстур путём модификации UV-значений (стр. 121-128)

**Эффект для дороги (асфальт движется):**

```hlsl
Shader "Custom/ScrollingRoad" {
    Properties {
        _MainTex ("Road Texture", 2D) = "white" {}
        _ScrollSpeed ("Scroll Speed", Range(0, 5)) = 1
        _SpeedMultiplier ("Speed Multiplier", Float) = 10
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        
        CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _MainTex;
        float _ScrollSpeed;
        float _SpeedMultiplier;
        
        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // UV прокрутка по Y оси
            fixed2 scrolledUV = IN.uv_MainTex;
            scrolledUV.y += _Time.y * _ScrollSpeed * _SpeedMultiplier;
            
            half4 c = tex2D(_MainTex, scrolledUV);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
```

**Для гоночной игры:**
- Прокрутка текстуры дороги для эффекта скорости
- Анимация текстуры шин
- Движущиеся облака на небе

---

#### 4.3 Создание прозрачного материала (стр. 129-136)

**Прозрачность для стёкол автомобиля:**

```hlsl
Shader "Custom/CarGlass" {
    Properties {
        _MainColor ("Glass Color", Color) = (0.5, 0.7, 0.9, 0.3)
        _Transparency ("Transparency", Range(0, 1)) = 0.7
        _ReflectionStrength ("Reflection", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags { 
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalPipeline"
        }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        
        Pass {
            // ... vertex shader ...
            
            float4 frag(Varyings input) : SV_Target {
                float4 color = _MainColor;
                color.a *= _Transparency;
                return color;
            }
        }
    }
}
```

---

#### 4.4 Упаковка и смешивание текстур (стр. 137-146)

**Terrain blending для трассы:**

```hlsl
Shader "Custom/TerrainBlend" {
    Properties {
        _LayerA ("Layer A Texture", 2D) = "white" {}
        _LayerB ("Layer B Texture", 2D) = "white" {}
        _BlendMap ("Blend Map (R)", 2D) = "white" {}
    }
    SubShader {
        CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _LayerA;
        sampler2D _LayerB;
        sampler2D _BlendMap;
        
        struct Input {
            float2 uv_LayerA;
            float2 uv_LayerB;
            float2 uv_BlendMap;
        };
        
        void surf (Input IN, inout SurfaceOutputStandard o) {
            float4 blendData = tex2D(_BlendMap, IN.uv_BlendMap);
            float4 layerA = tex2D(_LayerA, IN.uv_LayerA);
            float4 layerB = tex2D(_LayerB, IN.uv_LayerB);
            
            // Lerp смешивание по R каналу blend map
            float4 finalColor = lerp(layerA, layerB, blendData.r);
            
            o.Albedo = finalColor.rgb;
            o.Alpha = finalColor.a;
        }
        ENDCG
    }
}
```

---

#### 4.5 Создание круга вокруг ландшафта (стр. 147-152)

**Эффект для границы трассы:**

```hlsl
Shader "Custom/TerrainCircle" {
    Properties {
        _Center ("Center", Vector) = (0, 0, 0, 0)
        _Radius ("Radius", Float) = 50
        _EdgeSoftness ("Edge Softness", Range(0, 10)) = 5
        _InnerColor ("Inner Color", Color) = (1, 1, 1, 1)
        _OuterColor ("Outer Color", Color) = (0, 0, 0, 0)
    }
    
    // В fragment shader:
    float distanceFromCenter = distance(worldPos.xz, _Center.xz);
    float circleMask = 1 - smoothstep(_Radius - _EdgeSoftness, _Radius, distanceFromCenter);
    float3 finalColor = lerp(_OuterColor.rgb, _InnerColor.rgb, circleMask);
}
```

---

### Глава 5: Улучшение реализма: Unity Muse и PBR

#### 5.1 Использование генеративного ИИ для создания текстур (стр. 157-164)

**Unity Muse Texture workflow:**
1. Открыть Muse Texture в Unity
2. Ввести prompt: "racing track asphalt with tire marks"
3. Сгенерировать варианты
4. Экспортировать в проект

**Примеры prompts для гоночной игры:**
- "worn racing asphalt with rubber marks and oil stains"
- "carbon fiber texture for car body"
- "leather interior texture with stitching"
- "neon sign texture for garage"

---

#### 5.2 Понимание настройки металличности (стр. 165-172)

**PBR Metallic workflow:**

| Материал | Metallic | Smoothness |
|----------|----------|------------|
| **Хром** | 1.0 | 0.95 |
| **Алюминий** | 0.8 | 0.7 |
| **Крашеный металл** | 0.6 | 0.5 |
| **Пластик** | 0.0 | 0.4 |
| **Резина (шины)** | 0.0 | 0.3 |
| **Стекло** | 0.0 | 0.9 |
| **Карбон** | 0.3 | 0.6 |

**Для кузова автомобиля:**
```
Base Layer:
- Metallic: 0.7-0.8
- Smoothness: 0.6-0.7

Clear Coat Layer:
- Metallic: 0.0
- Smoothness: 0.9-0.95
```

---

#### 5.3 Создание зеркал и отражающих поверхностей (стр. 173-182)

**Reflection Probe настройка:**

```
Reflection Probe Settings:
- Type: Realtime (для динамических объектов)
- Resolution: 256x256 или выше
- Shadow Distance: 50-100m
- Refresh Mode: Via Scripting (для оптимизации)
```

**Shader для зеркала заднего вида:**

```hlsl
Shader "Custom/CarMirror" {
    Properties {
        _ReflectionProbe ("Reflection Probe", Cube) = "" {}
        _Tint ("Tint", Color) = (0.8, 0.8, 0.8, 1)
    }
    
    // В fragment shader:
    float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
    float3 reflectDir = reflect(-viewDir, normal);
    float4 reflection = texCUBE(_ReflectionProbe, reflectDir);
    return reflection * _Tint;
}
```

---

#### 5.4 Запекание света в сцене (стр. 183-192)

**Lightmap baking для гаража:**

```
Lighting Settings:
- Lightmap Resolution: 40-60 texels/unit
- Lightmap Padding: 2
- Lightmap Size: 2048 или 4096
- Compress Lightmaps: false (для качества)

Объекты:
- Статичная геометрия: Static ✓
- Динамические объекты: не запекать
- Light Probes: вокруг трассы
```

---

## Часть II: Продвинутые шейдерные эффекты и манипуляция геометрией

### Глава 6: Использование вершинных функций

#### 6.1 Доступ к цвету вершины в Shader Graph (стр. 197-202)

**Vertex Color для damage системы:**

```
Shader Graph:
Position (Object) → 
    ↓
Vertex Color node → 
    ↓
Multiply с damage intensity →
    ↓
Lerp между base color и damage color
```

**Применение:**
- Отображение повреждений кузова
- Грязь на автомобиле
- Износ шин

---

#### 6.2 Анимация вершин в Shader Graph (стр. 203-210)

**Эффект heat haze (тепловая дрожь):**

```
Shader Graph для heat distortion:
Position (Object)
    ↓
Add (с Simple Noise × Time × Intensity)
    ↓
Position (Output)

UV
    ↓
Simple Noise (animated)
    ↓
Multiply с Intensity
    ↓
Add к Position
```

**Для гоночной игры:**
- Тепловая дрожь над асфальтом в жару
- Выхлопные газы
- Эффект нитро

---

#### 6.3 Экструдирование моделей (стр. 211-216)

**Эффект для damage (вмятины):**

```hlsl
Shader "Custom/ExtrudeDamage" {
    Properties {
        _ExtrudeAmount ("Extrude Amount", Range(-1, 1)) = 0
        _ExtrudeTexture ("Extrude Map", 2D) = "gray" {}
    }
    
    // В vertex shader:
    float extrudeValue = tex2Dlod(_ExtrudeTexture, float4(uv, 0, 0)).r;
    float3 newPosition = positionOS + normalOS * extrudeValue * _ExtrudeAmount;
```

---

#### 6.4 Реализация шейдера снега (стр. 217-224)

**Снег на автомобиле (для зимних трасс):**

```hlsl
Shader "Custom/SnowOnCar" {
    Properties {
        _SnowColor ("Snow Color", Color) = (0.95, 0.95, 1, 1)
        _SnowAmount ("Snow Amount", Range(0, 1)) = 0.5
        _SnowSmoothness ("Snow Smoothness", Range(0, 1)) = 0.3
    }
    
    // В fragment shader:
    float snowMask = saturate(dot(normal, float3(0, 1, 0)));
    snowMask = smoothstep(0.3, 0.7, snowMask);
    snowMask *= _SnowAmount;
    
    float3 finalColor = lerp(baseColor, _SnowColor, snowMask);
```

---

#### 6.5 Реализация объёмного взрыва (стр. 225-234)

**VFX Graph для взрывов:**

```
VFX Graph Explosion:
- Initialize Particle:
  - Position: Sphere
  - Velocity: Random direction, speed 20-50
- Update Particle:
  - Drag: 0.5
  - Gravity: -9.8
- Output Particle Quad:
  - Texture: Fire/Smoke sequence
  - Blend Mode: Additive
  - Size: Animated (grow over time)
```

**Для гоночной игры:**
- Взрывы при авариях
- Эффекты нитро-буста
- Огонь из выхлопной трубы

---

### Глава 7: Использование Grab Pass

#### 7.1 Grab Pass для отрисовки за объектами (стр. 239-244)

**Эффект для прозрачных панелей:**

```hlsl
Shader "Custom/GrabPassTransparent" {
    Properties {
        _MainColor ("Color", Color) = (1, 1, 1, 0.5)
    }
    
    SubShader {
        Tags { "Queue"="Transparent" }
        
        Grab { }
        
        Pass {
            // Обработка захваченного изображения
            float4 grabPos = COMPUTE_GRAB_POS(input.positionCS);
            float4 grabbedColor = tex2Dproj(_GrabTexture, grabPos);
            return lerp(grabbedColor, _MainColor, _MainColor.a);
        }
    }
}
```

---

#### 7.2 Реализация шейдера стекла (стр. 245-254)

**Стекло с искажением для гоночной игры:**

```hlsl
Shader "Custom/CarGlassDistortion" {
    Properties {
        _GlassColor ("Glass Color", Color) = (0.5, 0.7, 0.9, 0.3)
        _DistortionStrength ("Distortion", Range(0, 0.1)) = 0.02
        _NormalMap ("Normal Map", 2D) = "bump" {}
    }
    
    SubShader {
        Tags { "Queue"="Transparent" }
        Grab { }
        
        Pass {
            float4 grabPos = COMPUTE_GRAB_POS(positionCS);
            
            // Искажение UV через нормаль
            float2 distortion = UnpackNormal(tex2D(_NormalMap, uv)).xy;
            grabPos.xy += distortion * _DistortionStrength;
            
            float4 grabbedColor = tex2Dproj(_GrabTexture, grabPos);
            return lerp(grabbedColor, _GlassColor, _GlassColor.a);
        }
    }
}
```

**Применение:**
- Лобовое стекло
- Боковые окна
- Зеркала заднего вида

---

#### 7.3 Реализация шейдера воды для 2D-игр (стр. 255-262)

**Вода для 2D гонок:**

```hlsl
Shader "Custom/2DWater" {
    Properties {
        _WaterColor ("Water Color", Color) = (0, 0.5, 1, 0.6)
        _WaveSpeed ("Wave Speed", Range(0, 5)) = 1
        _WaveHeight ("Wave Height", Range(0, 0.5)) = 0.1
    }
    
    // В fragment shader:
    float wave = sin(uv.x * 10 + _Time.y * _WaveSpeed) * _WaveHeight;
    float2 waveUV = uv + float2(0, wave);
    float4 waterColor = tex2D(_MainTex, waveUV) * _WaterColor;
```

---

## Часть III: Оптимизация производительности и полноэкранные эффекты

### Глава 8: Оптимизация шейдеров

#### 8.1 Техники повышения эффективности шейдеров (стр. 267-276)

**Оптимизации для мобильных устройств:**

| Техника | Описание | Экономия |
|---------|----------|----------|
| **half вместо float** | Меньшая точность, быстрее на GPU | 2x быстрее |
| **Уменьшение инструкций** | Упростить вычисления | 20-50% |
| **Texture Atlasing** | Объединить текстуры | Меньше draw calls |
| **LOD для шейдеров** | Упрощённые шейдеры вдали | 30-60% |
| **Instancing** | Одинаковые объекты | 10x больше объектов |

**Пример оптимизации:**

```hlsl
// ПЛОХО — избыточная точность
float4 color = tex2D(_MainTex, uv);
float result = pow(color.r, 2.2) + pow(color.g, 2.2) + pow(color.b, 2.2);

// ХОРОШО — half для цвета
half4 color = tex2D(_MainTex, uv);
half result = dot(color.rgb, half3(0.33, 0.33, 0.33));
```

---

#### 8.2 Профилирование шейдеров (стр. 277-284)

**Unity Profiler для шейдеров:**

```
Window → Analysis → Profiler
- GPU Usage module
- Rendering module
- Frame Debugger

Метрики для отслеживания:
- SetPass Calls
- Batches
- Vertices
- Triangles
- Screen Resolution
```

**Frame Debug для анализа:**
```
Window → Analysis → Frame Debugger
- Пошаговый просмотр рендеринга
- Поиск узких мест
- Анализ overdraw
```

---

#### 8.3 Модификация шейдеров для мобильных (стр. 285-292)

**Mobile-оптимизированный шейдер:**

```hlsl
Shader "Custom/MobileCarPaint" {
    Properties {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0.5
    }
    
    SubShader {
        Tags { "RenderPipeline"="UniversalPipeline" }
        LOD 150 // Низкий LOD для мобильных
        
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0 // Минимальная target
            
            // Использовать half вместо float
            half4 frag(Varyings input) : SV_Target {
                half4 color = _BaseColor;
                return color;
            }
            ENDHLSL
        }
    }
}
```

---

### Глава 9: Создание экранных эффектов с полноэкранными шейдерами

#### 9.1 Создание простого полноэкранного шейдера (стр. 297-302)

**Базовый fullscreen shader:**

```hlsl
Shader "Hidden/Custom/FullscreenBasic" {
    SubShader {
        Cull Off ZWrite Off ZTest Always
        
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            Varyings vert(uint vertexID : SV_VertexID) {
                Varyings output;
                output.uv = float2((vertexID << 1) & 2, vertexID & 2);
                output.positionCS = float4(output.uv * float2(2, -2) + float2(-1, 1), 0, 1);
                return output;
            }
            
            float4 frag(Varyings input) : SV_Target {
                return tex2D(_MainTex, input.uv);
            }
            ENDHLSL
        }
    }
}
```

---

#### 9.2 Настройка яркости, насыщенности и контраста (стр. 303-310)

**Post-processing для гоночной игры:**

```hlsl
float3 AdjustBrightnessSaturationContrast(float3 color, float brightness, float saturation, float contrast) {
    // Brightness
    color += brightness;
    
    // Contrast
    color = (color - 0.5) * contrast + 0.5;
    
    // Saturation
    float gray = dot(color, float3(0.299, 0.587, 0.114));
    color = lerp(gray, color, saturation);
    
    return saturate(color);
}
```

**Настройки для разных режимов:**

| Режим | Brightness | Saturation | Contrast |
|-------|------------|------------|----------|
| **День** | 0 | 1.1 | 1.05 |
| **Ночь** | -0.05 | 0.9 | 1.1 |
| **Дождь** | -0.1 | 0.8 | 1.15 |
| **Закат** | 0.05 | 1.3 | 1.0 |

---

#### 9.3 Режимы наложения как в Photoshop (стр. 311-320)

**Blend modes для UI:**

```hlsl
// Multiply
float3 Multiply(float3 base, float3 blend) {
    return base * blend;
}

// Screen
float3 Screen(float3 base, float3 blend) {
    return 1 - (1 - base) * (1 - blend);
}

// Overlay
float3 Overlay(float3 base, float3 blend) {
    return base < 0.5 ? 2 * base * blend : 1 - 2 * (1 - base) * (1 - blend);
}

// Additive (для неона)
float3 Additive(float3 base, float3 blend) {
    return saturate(base + blend);
}
```

---

#### 9.4 Включение и отключение функций рендеринга скриптом (стр. 321-326)

**C# скрипт для переключения эффектов:**

```csharp
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class RaceEffectsController : MonoBehaviour
{
    public Volume volume;
    public Bloom bloom;
    public MotionBlur motionBlur;
    public ColorAdjustments colorAdjustments;
    
    private bool isNitroActive = false;
    
    void Start()
    {
        volume.profile.TryGet(out bloom);
        volume.profile.TryGet(out motionBlur);
        volume.profile.TryGet(out colorAdjustments);
    }
    
    public void ActivateNitro()
    {
        isNitroActive = true;
        bloom.intensity.Override(3f);
        motionBlur.intensity.Override(0.85f);
        colorAdjustments.saturation.Override(1.3f);
    }
    
    public void DeactivateNitro()
    {
        isNitroActive = false;
        bloom.intensity.Override(1.5f);
        motionBlur.intensity.Override(0.5f);
        colorAdjustments.saturation.Override(1.1f);
    }
    
    public void SetWeatherRain()
    {
        colorAdjustments.saturation.Override(0.8f);
        colorAdjustments.contrast.Override(1.15f);
        colorAdjustments.colorFilter.Override(new Color(0.8f, 0.85f, 0.95f));
    }
}
```

---

### Глава 10: Игровые и экранные эффекты

#### 10.1 Создание эффекта старого кино (стр. 331-338)

**Retro эффект для replay:**

```hlsl
Shader "Hidden/Custom/OldMovie" {
    Properties {
        _MainTex ("Source", 2D) = "" {}
        _GrainIntensity ("Grain", Range(0, 1)) = 0.3
        _VignetteIntensity ("Vignette", Range(0, 1)) = 0.5
        _SepiaIntensity ("Sepia", Range(0, 1)) = 0.7
        _ScratchIntensity ("Scratches", Range(0, 1)) = 0.2
    }
    
    float4 frag(Varyings input) : SV_Target {
        float4 color = tex2D(_MainTex, input.uv);
        
        // Film grain
        float grain = random(input.uv * _Time.y) * _GrainIntensity;
        color.rgb += grain;
        
        // Vignette
        float vignette = 1 - length(input.uv - 0.5) * 2;
        vignette = pow(vignette, 2) * _VignetteIntensity;
        color.rgb *= vignette;
        
        // Sepia
        float3 sepia = float3(0.393, 0.769, 0.189);
        float gray = dot(color.rgb, float3(0.299, 0.587, 0.114));
        color.rgb = lerp(color.rgb, gray * sepia * 3, _SepiaIntensity);
        
        return color;
    }
}
```

---

#### 10.2 Создание эффекта ночного видения (стр. 339-346)

**Night vision для ночных гонок:**

```hlsl
Shader "Hidden/Custom/NightVision" {
    Properties {
        _MainTex ("Source", 2D) = "" {}
        _GreenTint ("Green Tint", Color) = (0.5, 1, 0.5, 1)
        _ScanLineSpeed ("Scan Speed", Range(0, 5)) = 1
    }
    
    float4 frag(Varyings input) : SV_Target {
        float4 color = tex2D(_MainTex, input.uv);
        
        // Зеленый оттенок
        color.rgb *= _GreenTint.rgb;
        
        // Сканирующие линии
        float scanLine = sin(input.uv.y * 200 - _Time.y * _ScanLineSpeed);
        scanLine = smoothstep(-0.5, 0.5, scanLine) * 0.1;
        color.rgb += scanLine;
        
        // Хроматическая аберрация по краям
        float dist = length(input.uv - 0.5);
        color.r = tex2D(_MainTex, input.uv + float2(dist * 0.01, 0)).r;
        color.b = tex2D(_MainTex, input.uv - float2(dist * 0.01, 0)).b;
        
        return color;
    }
}
```

---

## Часть IV: Пользовательское освещение и продвинутое программирование шейдеров

### Глава 11: Понимание моделей освещения

#### 11.1 Создание пользовательской модели диффузного освещения (стр. 351-356)

**Custom diffuse для стилизованной графики:**

```hlsl
inline float4 LightingCustomDiffuse(SurfaceOutput s, fixed3 lightDir, fixed atten) {
    float difLight = max(0, dot(s.Normal, lightDir));
    
    // Кастомная кривая затенения
    difLight = pow(difLight, 0.5); // Сделать светлее в тенях
    
    float4 col;
    col.rgb = s.Albedo * _LightColor0.rgb * (difLight * atten * 2);
    col.a = s.Alpha;
    return col;
}
```

---

#### 11.2 Создание toon-шейдера (стр. 357-366)

**Cel-shading для стилизованной гоночной игры:**

```hlsl
Shader "Custom/ToonCar" {
    Properties {
        _MainColor ("Base Color", Color) = (1, 0, 0, 1)
        _ShadowColor ("Shadow Color", Color) = (0.3, 0, 0, 1)
        _ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.3
    }
    
    inline float4 LightingToon(SurfaceOutput s, fixed3 lightDir, fixed atten) {
        float NdotL = dot(s.Normal, lightDir);
        
        // Резкий переход между светом и тенью
        float lightIntensity = step(_ShadowThreshold, NdotL);
        
        float4 col;
        col.rgb = lerp(_ShadowColor.rgb, _MainColor.rgb, lightIntensity);
        col.rgb *= _LightColor0.rgb * atten * 2;
        col.a = s.Alpha;
        return col;
    }
}
```

**Применение:**
- Стилизованные гоночные игры
- Мультяшный визуальный стиль
- Инди-проекты

---

#### 11.3 Blinn-Phong Specular (стр. 367-374)

**Blinn-Phong для металлических поверхностей:**

```hlsl
inline float4 LightingBlinnPhongCustom(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten) {
    half3 halfVector = normalize(lightDir + viewDir);
    
    float NdotL = max(0, dot(s.Normal, lightDir));
    float NdotH = max(0, dot(s.Normal, halfVector));
    float spec = pow(NdotH, s.Specular * 128) * s.Gloss;
    
    float4 c;
    c.rgb = s.Albedo * _LightColor0.rgb * NdotL;
    c.rgb += _SpecColor.rgb * spec * (_LightColor0.rgb * atten * 2);
    c.a = s.Alpha;
    return c;
}
```

---

#### 11.4 Анизотропная специфичность (стр. 375-382)

**Anisotropic для拉丝金属 (brushed metal):**

```hlsl
Shader "Custom/AnisotropicMetal" {
    Properties {
        _MainColor ("Base Color", Color) = (1, 1, 1, 1)
        _AnisoDirection ("Aniso Direction", Vector) = (1, 0, 0, 0)
        _AnisoStrength ("Aniso Strength", Range(0, 1)) = 0.5
        _AnisoPower ("Aniso Power", Range(1, 100)) = 20
    }
    
    // В fragment shader:
    float3 tangent = normalize(_AnisoDirection.xyz);
    float3 bitangent = cross(normal, tangent);
    float3 halfVector = normalize(lightDir + viewDir);
    
    float aniso = dot(halfVector, bitangent);
    float spec = pow(abs(aniso), _AnisoPower) * _AnisoStrength;
```

**Применение:**
-拉丝金属 кузова
- CD/DVD поверхность
- Волосы

---

### Глава 12: Разработка продвинутых техник затенения

#### 12.1 Использование URP Shader Library (стр. 387-394)

**Включение URP библиотек:**

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

// Использование встроенных функций:
Light mainLight = GetMainLight();
float3 color = mainLight.color * mainLight.distanceAttenuation;

// PBR BRDF
BRDFData brdfData;
InitializeBRDFData(albedo, metallic, smoothness, alpha, brdfData);
float3 radiance = DirectBDRF(brdfData, normal, viewDir, lightDir);
```

---

#### 12.2 Модульный шейдер с HLSL include-файлами (стр. 395-400)

**Структура проекта:**

```
Assets/
├── Shaders/
│   ├── Includes/
│   │   ├── Common.hlsl
│   │   ├── Lighting.hlsl
│   │   └── Utilities.hlsl
│   ├── CarPaint.shadergraph
│   └── Glass.shadergraph
```

**Common.hlsl:**

```hlsl
#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED

// Общие константы
#define PI 3.14159265359
#define EPSILON 1e-6

// Утилиты
float Random(float2 uv) {
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float Noise(float2 uv) {
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3 - 2 * f);
    
    float a = Random(i);
    float b = Random(i + float2(1, 0));
    float c = Random(i + float2(0, 1));
    float d = Random(i + float2(1, 1));
    
    return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

#endif
```

---

#### 12.3 Реализация шейдера меха (Fur) (стр. 401-410)

**Fur shader для маскотов/талисманов:**

```hlsl
Shader "Custom/Fur" {
    Properties {
        _FurColor ("Fur Color", Color) = (0.5, 0.3, 0.1, 1)
        _FurLength ("Fur Length", Range(0, 0.5)) = 0.1
        _FurDensity ("Fur Density", Range(1, 100)) = 30
    }
    
    // Shell-based fur technique
    // Multiple passes с increasing extrusion
}
```

---

#### 12.4 Тепловые карты с массивами (стр. 411-418)

**Heatmap для трассы (износ шин):**

```csharp
// C# скрипт для передачи данных
public class TireHeatmap : MonoBehaviour
{
    public Material tireMaterial;
    public Vector4[] heatData;
    
    void Update()
    {
        // Обновление данных о температуре шин
        tireMaterial.SetVectorArray("_HeatPositions", heatData);
    }
}
```

```hlsl
// В shader:
CBUFFER_START(UnityPerMaterial)
    float4 _HeatPositions[16];
CBUFFER_END

float CalculateHeat(float3 position) {
    float totalHeat = 0;
    for (int i = 0; i < _HeatCount; i++) {
        float dist = distance(position, _HeatPositions[i].xyz);
        totalHeat += _HeatPositions[i].w * exp(-dist * 10);
    }
    return totalHeat;
}
```

---

### Глава 13: Использование HDRP

#### 13.1 Система светящегося выделения (стр. 423-430)

**Glow effect для UI и неона:**

```
HDRP Settings:
- Bloom:
  - Threshold: 0.8
  - Intensity: 2.0
  - Scatter: 0.8
  - Tint: Neon color
  
- Emissive:
  - Intensity: 100000+ nits
  - Color: RGB (0-1)
```

---

#### 13.2 Портал-шейдеры (стр. 431-440)

**Portal для телепортации между трассами:**

```hlsl
// Portal rendering с stencil buffer
Stencil {
    Ref 1
    Comp Always
    Pass Replace
}

// Рендеринг сцены через портал
// Camera с target texture
// Projection matrix для matching portal
```

---

## 🔑 Ключевые темы

### Шейдеры

| Тип | Описание | Страницы |
|-----|----------|----------|
| **PBR Shader** | Физически корректный рендеринг | 165-172 |
| **Toon Shader** | Сел-шейдинг для стилизации | 357-366 |
| **Holographic** | Голографический эффект | 103-110 |
| **Glass/Distortion** | Стекло с искажением | 245-254 |
| **Water** | Вода для 2D/3D | 255-262, 520-528 |
| **Snow** | Снег на поверхностях | 217-224 |
| **Fur** | Шейдер меха | 401-410 |
| **Anisotropic** | Анизотропное отражение | 375-382 |

### VFX (Визуальные эффекты)

| Эффект | Описание | Страницы |
|--------|----------|----------|
| **Bloom** | Свечение ярких участков | 29-36 |
| **Motion Blur** | Размытие в движении | 29-36 |
| **Depth of Field** | Глубина резкости | 21-28 |
| **Volumetric Explosion** | Объёмный взрыв | 225-234 |
| **Heat Haze** | Тепловая дрожь | 203-210 |
| **Fire/Smoke** | Огонь и дым (VFX Graph) | 225-234 |

### URP Настройки

| Компонент | Описание | Страницы |
|-----------|----------|----------|
| **Post-processing Volume** | Глобальные эффекты | 15-50 |
| **Reflection Probes** | Отражения | 173-182 |
| **Light Probes** | Освещение динамических объектов | 183-192 |
| **Shadow Settings** | Настройки теней | 367-374 |
| **Renderer Features** | Кастомные эффекты рендеринга | 321-326 |

---

## 💻 Примеры кода

### HLSL Shader — Car Paint с Clear Coat

```hlsl
Shader "DragRace/CarPaint" {
    Properties {
        _BaseColor ("Base Color", Color) = (1, 0, 0, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0.8
        _Smoothness ("Smoothness", Range(0, 1)) = 0.7
        _ClearCoat ("Clear Coat", Range(0, 1)) = 0.9
        _ClearCoatSmoothness ("Clear Coat Smoothness", Range(0, 1)) = 0.95
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _DecalTex ("Decal Texture", 2D) = "white" {}
    }
    
    SubShader {
        Tags { "RenderPipeline"="UniversalPipeline" }
        LOD 300
        
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };
            
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _Metallic;
                float _Smoothness;
                float _ClearCoat;
                float _ClearCoatSmoothness;
            CBUFFER_END
            
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_DecalTex);
            SAMPLER(sampler_DecalTex);
            
            Varyings vert(Attributes input) {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
                output.uv = input.uv;
                return output;
            }
            
            float4 frag(Varyings input) : SV_Target {
                // Нормаль из текстуры
                float3 normalTS = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv).xyz * 2 - 1;
                float3 normalWS = normalize(mul(normalTS, float3x3(input.tangentWS, 
                    cross(input.normalWS, input.tangentWS), input.normalWS)));
                
                // Декали (логотипы спонсоров)
                float4 decal = SAMPLE_TEXTURE2D(_DecalTex, sampler_DecalTex, input.uv);
                float3 albedo = lerp(_BaseColor.rgb, decal.rgb, decal.a);
                
                // Освещение
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
                float NdotL = saturate(dot(normalWS, mainLight.direction));
                
                // PBR расчёт
                float3 halfDir = normalize(mainLight.direction + normalize(_WorldSpaceCameraPos - input.positionWS));
                float NdotH = saturate(dot(normalWS, halfDir));
                float spec = pow(NdotH, (1 - _Smoothness) * 128);
                
                // Clear coat слой
                float clearCoatSpec = pow(NdotH, (1 - _ClearCoatSmoothness) * 256) * _ClearCoat;
                
                float3 finalColor = albedo * mainLight.color * NdotL;
                finalColor += mainLight.color * spec * _Metallic;
                finalColor += mainLight.color * clearCoatSpec;
                
                return float4(finalColor, 1);
            }
            ENDHLSL
        }
    }
}
```

---

### C# Скрипт — Динамическая смена погоды

```csharp
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace DragRaceUnity.Effects
{
    public class WeatherController : MonoBehaviour
    {
        [Header("References")]
        public Volume globalVolume;
        
        [Header("Profiles")]
        public VolumeProfile sunnyProfile;
        public VolumeProfile rainyProfile;
        public VolumeProfile nightProfile;
        public VolumeProfile sunsetProfile;
        
        [Header("Settings")]
        public float transitionDuration = 2f;
        
        private float transitionTimer = 0f;
        private VolumeProfile currentProfile;
        private VolumeProfile targetProfile;
        private bool isTransitioning = false;
        
        void Start()
        {
            if (globalVolume == null)
                globalVolume = FindObjectOfType<Volume>();
            
            SetWeather(WeatherType.Sunny);
        }
        
        public enum WeatherType { Sunny, Rainy, Night, Sunset }
        
        public void SetWeather(WeatherType type)
        {
            targetProfile = type switch
            {
                WeatherType.Sunny => sunnyProfile,
                WeatherType.Rainy => rainyProfile,
                WeatherType.Night => nightProfile,
                WeatherType.Sunset => sunsetProfile,
                _ => sunnyProfile
            };
            
            if (globalVolume.profile != targetProfile)
            {
                currentProfile = globalVolume.profile;
                isTransitioning = true;
                transitionTimer = 0f;
            }
        }
        
        void Update()
        {
            if (isTransitioning)
            {
                transitionTimer += Time.deltaTime / transitionDuration;
                
                if (transitionTimer >= 1f)
                {
                    globalVolume.profile = targetProfile;
                    isTransitioning = false;
                    transitionTimer = 0f;
                }
            }
        }
        
        // Быстрые пресеты для гоночных ситуаций
        public void ActivateNitroVision()
        {
            var profile = globalVolume.profile;
            if (profile.TryGet<Bloom>(out var bloom))
                bloom.intensity.Override(3f);
            if (profile.TryGet<MotionBlur>(out var motionBlur))
                motionBlur.intensity.Override(0.85f);
            if (profile.TryGet<ColorAdjustments>(out var color))
            {
                color.saturation.Override(1.3f);
                color.contrast.Override(1.1f);
            }
        }
        
        public void ActivateDamageEffect(float damageAmount)
        {
            // Эффект повреждения при ударе
            var profile = globalVolume.profile;
            if (profile.TryGet<ColorAdjustments>(out var color))
            {
                color.saturation.Override(Mathf.Lerp(1.1f, 0.5f, damageAmount));
                color.contrast.Override(Mathf.Lerp(1.05f, 1.3f, damageAmount));
            }
            
            // Flash effect
            StartCoroutine(FlashRoutine(damageAmount));
        }
        
        System.Collections.IEnumerator FlashRoutine(float intensity)
        {
            var profile = globalVolume.profile;
            if (!profile.TryGet<ColorAdjustments>(out var color))
                yield break;
                
            float originalBrightness = color.brightness.value;
            color.brightness.Override(originalBrightness + intensity * 0.5f);
            
            yield return new WaitForSeconds(0.1f);
            
            color.brightness.Override(originalBrightness);
        }
    }
}
```

---

### Shader Graph — Неоновая подсветка автомобиля

```
Shader Graph: Neon Underglow

Blackboard:
- _NeonColor (Color) = (0, 1, 1, 1)
- _Intensity (Vector1) = 2.0
- _PulseSpeed (Vector1) = 2.0
- _NormalMap (Texture2D)

Nodes:
1. Time → Multiply (с _PulseSpeed) → Sine
2. Sine Output → Remap (0 to 1) → Multiply (с _Intensity)
3. Sample Texture 2D (_NormalMap) → Normal Unpack
4. Position (World) → Split (Y компонент)
5. Split Y → Greater Than (0) → Mask для нижней части
6. Remap × Mask → Multiply с _NeonColor
7. Output → Emission (PBR Master)

Settings:
- Surface Type: Transparent
- Blend Mode: Additive
- Render Queue: 3000
```

---

## ✅ Лучшие практики

### Производительность

| Практика | Описание | Влияние |
|----------|----------|---------|
| **LOD для шейдеров** | Упрощённые шейдеры на расстоянии | 30-60% FPS |
| **Texture Atlasing** | Объединение текстур | Меньше draw calls |
| **GPU Instancing** | Одинаковые объекты | 10x больше объектов |
| **Half precision** | half вместо float | 2x быстрее на mobile |
| **Baked Lighting** | Запекание статичного света | 50% меньше GPU |

### Качество

| Практика | Описание | Результат |
|----------|----------|-----------|
| **PBR Workflow** | Металличность + гладкость | Реалистичные материалы |
| **Post-processing Stack** | Bloom + Motion Blur + DOF | Кинематографичный вид |
| **Reflection Probes** | Динамические отражения | Реальные отражения |
| **Normal Mapping** | Детализация без полигонов | Высокая детализация |

### Организация

| Практика | Описание |
|----------|----------|
| **Модульные шейдеры** | HLSL include-файлы |
| **Именование** | Четкие имена (_BaseColor, не _Color1) |
| **Версионирование** | Git для shader-файлов |
| **Документация** | Комментарии в коде |

---

## 🎯 Лучшие практики для DragRaceUnity

### 1. Шейдеры для автомобиля

**Car Paint (Кузов):**
```
- PBR с Clear Coat слоем
- Metallic: 0.7-0.8
- Smoothness: 0.6-0.7 (base), 0.95 (clear coat)
- Normal map для деталей панелей
- Decal texture для логотипов спонсоров
- LOD: 3 уровня детализации
```

**Car Glass (Стёкла):**
```
- Grab Pass с distortion
- Transparency: 0.3-0.5
- Reflection Probe для окружения
- Normal map для тонких искажений
```

**Car Tires (Шины):**
```
- PBR с низким smoothness (0.2-0.3)
- Normal map для протектора
- Heatmap для температуры (износ)
- Vertex color для грязи
```

**Neon Underglow (Подсветка):**
```
- Additive blend mode
- Animated emission intensity
- Pulse effect (sine wave)
- Color customization через MaterialPropertyBlock
```

---

### 2. Эффекты для трассы

**Road Surface (Асфальт):**
```
- Scrolling UV для эффекта движения
- Normal map для неровностей
- Wet map для дождя (smoothness variation)
- Tire marks texture (декали)
```

**Water Puddles (Лужи):**
```
- Grab Pass с distortion
- Animated normal map (ripples)
- Reflection Probe
- Fade по distance от камеры
```

**Environment Fog (Туман):**
```
- URP Volumetric Fog
- Density: 0.01-0.05
- Color matching skybox
- Height-based variation
```

---

### 3. VFX для гонок

**Nitro Boost:**
```
VFX Graph:
- Particle burst при активации
- Trail renderer для синего шлейфа
- Distortion effect (heat haze)
- Sound sync через VFX events
- Duration: 3-5 секунд
- Cooldown: 10 секунд
```

**Tire Smoke (Дым от шин):**
```
VFX Graph:
- Continuous emission при burnout
- Particle size grow over time
- Color: white → gray → black
- Affected by wind zones
- LOD: отключать на расстоянии 100m+
```

**Explosion (Взрыв при аварии):**
```
VFX Graph:
- Initial fireball (additive)
- Secondary smoke plume
- Debris particles
- Camera shake (Cinemachine)
- Sound: layered explosion
```

**Speed Lines (Линии скорости):**
```
Shader Graph:
- Radial blur от центра экрана
- Intensity based on speed
- Color: white with motion blur
- Fade in/out при ускорении
```

---

### 4. Post-processing для гонок

**Default Racing Look:**
```
Volume Profile — "Racing_Default":
- Bloom: threshold 0.8, intensity 1.5
- Motion Blur: intensity 0.5, shutter angle 270
- Color Adjustments: saturation 1.1, contrast 1.05
- Vignette: intensity 0.2, roundness 0.5
- Film Grain: intensity 0.05
```

**Nitro Mode:**
```
Volume Profile — "Racing_Nitro":
- Bloom: threshold 0.6, intensity 3.0
- Motion Blur: intensity 0.85, shutter angle 360
- Color Adjustments: saturation 1.3, contrast 1.1
- Chromatic Aberration: 0.1
- Lens Distortion: 0.05
```

**Damage/Crash:**
```
Volume Profile — "Racing_Damage":
- Bloom: intensity 0.5 (temporary flash 5.0)
- Color Adjustments: saturation 0.5, contrast 1.3
- Vignette: intensity 0.8 (черные края)
- Film Grain: intensity 0.3
- Duration: 0.5-1 секунда
```

**Night Race:**
```
Volume Profile — "Racing_Night":
- Bloom: intensity 2.5 (для фар и неона)
- Color Adjustments: temperature -20, tint -10
- Vignette: intensity 0.4
- Depth of Field: focus on player car
```

---

### 5. Производительность для DragRaceUnity

**Target FPS:**
| Платформа | Target | Min |
|-----------|--------|-----|
| **PC (High)** | 144 | 60 |
| **PC (Medium)** | 60 | 30 |
| **Console** | 60 | 30 |
| **Mobile** | 30 | 24 |

**Оптимизации:**

```
1. Шейдеры:
   - Максимум 2 pass для основных материалов
   - LOD для всех шейдеров (3 уровня)
   - GPU instancing для одинаковых объектов

2. Текстуры:
   - Атлас для декалей (логотипы)
   - Mip maps для всех текстур
   - Compression: BC7 для color, BC5 для normal

3. VFX:
   - Max particles: 1000 на экране
   - Culling: отключать за пределами камеры
   - LOD: упрощать на расстоянии

4. Post-processing:
   - Отключать DOF на mobile
   - Снижать sample count для motion blur
   - Использовать Fast mode для bloom
```

**Profiler Targets:**
```
Frame Time: 16.67ms (60 FPS)
- Render: < 8ms
- Scripts: < 4ms
- Physics: < 2ms
- VFX: < 2ms

Draw Calls: < 500
Batches: < 100
Triangles: < 500k на кадр
```

---

### 6. Интеграция с Input System

```csharp
using UnityEngine;
using UnityEngine.InputSystem;

namespace DragRaceUnity.Effects
{
    public class RaceEffectsInput : MonoBehaviour
    {
        public WeatherController weatherController;
        public VFXController vfxController;
        
        private void OnEnable()
        {
            // Input System integration
            var playerInput = new PlayerInput();
            playerInput.Race.Nitro.started += ctx => ActivateNitro();
            playerInput.Race.Nitro.canceled += ctx => DeactivateNitro();
            playerInput.Race.LookBack.started += ctx => ActivateLookBack();
            playerInput.Race.LookBack.canceled += ctx => DeactivateLookBack();
        }
        
        void ActivateNitro()
        {
            vfxController.ActivateNitroVFX();
            weatherController.ActivateNitroVision();
            
            // Camera FOV increase
            Camera.main.fieldOfView = 90;
        }
        
        void DeactivateNitro()
        {
            vfxController.DeactivateNitroVFX();
            Camera.main.fieldOfView = 60;
        }
        
        void ActivateLookBack()
        {
            // Переключить камеру назад
            // Добавить motion blur
        }
        
        void DeactivateLookBack()
        {
            // Вернуть камеру вперёд
        }
    }
}
```

---

## 🎯 Применение в DragRaceUnity

### Файлы для создания

| Файл | Тип | Описание |
|------|-----|----------|
| `Assets/Shaders/CarPaint.shadergraph` | Shader Graph | Основной шейдер кузова |
| `Assets/Shaders/CarGlass.shadergraph` | Shader Graph | Шейдер стёкол |
| `Assets/Shaders/NeonUnderglow.shadergraph` | Shader Graph | Неоновая подсветка |
| `Assets/Shaders/RoadSurface.shadergraph` | Shader Graph | Асфальт с прокруткой |
| `Assets/VFX/NitroBoost.vfx` | VFX Graph | Эффект нитро |
| `Assets/VFX/TireSmoke.vfx` | VFX Graph | Дым от шин |
| `Assets/VFX/Explosion.vfx` | VFX Graph | Взрыв при аварии |
| `Assets/PostProcessing/Racing_Default.asset` | Volume Profile | Стандартный профиль |
| `Assets/PostProcessing/Racing_Nitro.asset` | Volume Profile | Режим нитро |
| `Assets/PostProcessing/Racing_Night.asset` | Volume Profile | Ночная гонка |
| `Assets/Scripts/Effects/WeatherController.cs` | C# | Контроллер погоды |
| `Assets/Scripts/Effects/VFXController.cs` | C# | Контроллер эффектов |
| `Assets/Scripts/Effects/RaceEffectsInput.cs` | C# | Интеграция с вводом |

---

### Timeline интеграция

```
Для катсцен и replay использовать Timeline:

1. Создать Timeline для pre-race cutscene
2. Добавить Animation Track для камеры
3. Добавить Activation Track для VFX
4. Добавить Signal Track для триггеров эффектов
5. Signal: ActivateNitroSignal → VFXController.ActivateNitroVFX()
```

---

## 🔗 Ссылки

- **Официальная страница книги:** https://www.packtpub.com/product/unity-6-shaders-and-effects-cookbook/9781835468579
- **GitHub репозиторий кода:** https://github.com/PacktPublishing/Unity-6-Shaders-and-Effects-Cookbook
- **Unity Shader Graph документация:** https://docs.unity3d.com/Manual/ShaderGraph.html
- **URP документация:** https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@latest
- **VFX Graph документация:** https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@latest

---

**Статус:** ✅ Завершено

**Последнее обновление:** 2026-03-01

**Автор конспекта:** Qwen Code Assistant

---

## 📊 Статистика книги

| Параметр | Значение |
|----------|----------|
| **Глав** | 13 |
| **Рецептов** | 50+ |
| **Страниц** | 532 |
| **Примеров кода** | 100+ |
| **Шейдеров** | 30+ |
| **VFX эффектов** | 15+ |

---

## 🏁 Ключевые выводы для DragRaceUnity

1. **PBR Workflow** — основа для реалистичных материалов автомобиля
2. **Post-processing Stack** — критичен для ощущения скорости и атмосферы
3. **VFX Graph** — для нитро, дыма, взрывов
4. **Shader Graph** — для кастомных эффектов (неон, стёкла)
5. **Оптимизация** — LOD, instancing, texture atlasing для 60+ FPS
6. **Динамическая погода** — Volume Profiles для разных условий
7. **Input System integration** — триггеры эффектов от действий игрока

---

**Конспект завершён! Все рецепты и техники готовы к внедрению в DragRaceUnity!** 🏎️💨
