using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace RacingGame.Effects
{
    /// <summary>
    /// Менеджер пост-обработки.
    /// Применяет эффекты из книги Unity 6 Shaders and Effects Cookbook, Глава 1
    /// </summary>
    public class PostProcessingManager : MonoBehaviour
    {
        [Header("Volume Profile")]
        [Tooltip("Профиль пост-обработки")]
        public VolumeProfile volumeProfile;

        [Header("Настройки эффектов")]
        [Tooltip("Виньетка для кинематографичности")]
        public bool enableVignette = true;
        
        [Tooltip("Зернистость для фильма эффекта")]
        public bool enableGrain = false;
        
        [Tooltip("Bloom для свечения")]
        public bool enableBloom = true;
        
        [Tooltip("Color Grading для настроения")]
        public bool enableColorGrading = true;

        private Volume _volume;
        private VolumeProfile _localProfile;

        private void Awake()
        {
            // Создаем Volume если нет
            _volume = GetComponent<Volume>();
            if (_volume == null)
            {
                _volume = gameObject.AddComponent<Volume>();
            }

            _volume.isGlobal = true;
            _volume.priority = 0;
        }

        private void Start()
        {
            ApplyPostProcessing();
        }

        /// <summary>
        /// Применить пост-обработку
        /// </summary>
        public void ApplyPostProcessing()
        {
            if (_volume == null)
            {
                Debug.LogError("[PostProcessing] Volume не найден!");
                return;
            }

            // Создаем или используем существующий профиль
            if (volumeProfile == null)
            {
                _localProfile = ScriptableObject.CreateInstance<VolumeProfile>();
                _volume.profile = _localProfile;
            }
            else
            {
                _volume.profile = volumeProfile;
            }

            // Добавляем эффекты
            AddVignette();
            AddBloom();
            AddColorGrading();
            AddFilmGrain();

            Debug.Log("[PostProcessing] Пост-обработка применена");
        }

        private void AddVignette()
        {
            if (!enableVignette) return;

            Vignette vignette;
            if (!_volume.profile.TryGet(out vignette))
            {
                vignette = _volume.profile.Add<Vignette>(true);
            }

            vignette.color.SetValue(new Color(0f, 0f, 0f, 1f));
            vignette.center.SetValue(new Vector2(0.5f, 0.5f));
            vignette.intensity.SetValue(0.35f);
            vignette.smoothness.SetValue(0.2f);
            vignette.roundness.SetValue(1f);
            vignette.rounded.SetValue(false);
        }

        private void AddBloom()
        {
            if (!enableBloom) return;

            Bloom bloom;
            if (!_volume.profile.TryGet(out bloom))
            {
                bloom = _volume.profile.Add<Bloom>(true);
            }

            bloom.threshold.SetValue(0.9f);
            bloom.intensity.SetValue(0.5f);
            bloom.scatter.SetValue(0.7f);
            bloom.clamp.SetValue(65472f);
            bloom.tint.SetValue(Color.white);
            bloom.highQualityFiltering.SetValue(false);
            bloom.skipIterations.SetValue(0);
        }

        private void AddColorGrading()
        {
            if (!enableColorGrading) return;

            ColorAdjustments colorAdjustments;
            if (!_volume.profile.TryGet(out colorAdjustments))
            {
                colorAdjustments = _volume.profile.Add<ColorAdjustments>(true);
            }

            // Настройки для гоночной атмосферы
            colorAdjustments.postExposure.SetValue(0f);
            colorAdjustments.contrast.SetValue(10f);
            colorAdjustments.colorFilter.SetValue(Color.white);
            colorAdjustments.hueShift.SetValue(0f);
            colorAdjustments.saturation.SetValue(5f);
        }

        private void AddFilmGrain()
        {
            if (!enableGrain) return;

            FilmGrain grain;
            if (!_volume.profile.TryGet(out grain))
            {
                grain = _volume.profile.Add<FilmGrain>(true);
            }

            grain.type.SetValue(FilmGrainType.Regular);
            grain.intensity.SetValue(0.3f);
            grain.response.SetValue(0.8f);
            grain.texture.SetValue(null);
        }

        /// <summary>
        /// Установить профиль пост-обработки
        /// </summary>
        public void SetProfile(VolumeProfile newProfile)
        {
            volumeProfile = newProfile;
            ApplyPostProcessing();
        }

        /// <summary>
        /// Включить/выключить виньетку
        /// </summary>
        public void SetVignette(bool enabled)
        {
            enableVignette = enabled;
            ApplyPostProcessing();
        }

        /// <summary>
        /// Включить/выключить Bloom
        /// </summary>
        public void SetBloom(bool enabled)
        {
            enableBloom = enabled;
            ApplyPostProcessing();
        }

        /// <summary>
        /// Установить интенсивность Bloom
        /// </summary>
        public void SetBloomIntensity(float intensity)
        {
            Bloom bloom;
            if (_volume.profile.TryGet(out bloom))
            {
                bloom.intensity.SetValue(Mathf.Clamp01(intensity));
            }
        }

        #region Presets (из книги Unity 6 Shaders Cookbook)

        /// <summary>
        /// Пресет: Кинематографичный вид
        /// </summary>
        public void ApplyCinematicPreset()
        {
            enableVignette = true;
            enableGrain = true;
            enableBloom = true;
            enableColorGrading = true;

            ApplyPostProcessing();

            // Дополнительные настройки
            Bloom bloom;
            if (_volume.profile.TryGet(out bloom))
            {
                bloom.intensity.SetValue(0.7f);
            }

            Debug.Log("[PostProcessing] Применен кинематографичный пресет");
        }

        /// <summary>
        /// Пресет: Хоррор атмосфера
        /// </summary>
        public void ApplyHorrorPreset()
        {
            enableVignette = true;
            enableGrain = false;
            enableBloom = false;
            enableColorGrading = true;

            ApplyPostProcessing();

            ColorAdjustments colorAdjustments;
            if (_volume.profile.TryGet(out colorAdjustments))
            {
                colorAdjustments.saturation.SetValue(-30f);
                colorAdjustments.contrast.SetValue(20f);
            }

            Debug.Log("[PostProcessing] Применен хоррор пресет");
        }

        /// <summary>
        /// Пресет: Яркая гонка
        /// </summary>
        public void ApplyRacingPreset()
        {
            enableVignette = false;
            enableGrain = false;
            enableBloom = true;
            enableColorGrading = true;

            ApplyPostProcessing();

            ColorAdjustments colorAdjustments;
            if (_volume.profile.TryGet(out colorAdjustments))
            {
                colorAdjustments.saturation.SetValue(20f);
                colorAdjustments.contrast.SetValue(5f);
            }

            Bloom bloom;
            if (_volume.profile.TryGet(out bloom))
            {
                bloom.intensity.SetValue(0.8f);
            }

            Debug.Log("[PostProcessing] Применен пресет гонки");
        }

        #endregion

        private void OnDisable()
        {
            if (_localProfile != null)
            {
                Destroy(_localProfile);
            }
        }
    }
}
