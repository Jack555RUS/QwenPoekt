using UnityEngine;
using ProbMenu.Core;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Effects
{
    /// <summary>
    /// Система частиц для эффектов
    /// Дым, искры, следы от шин
    /// </summary>
    public class CarEffects : MonoBehaviour
    {
        [Header("Системы частиц")]
        [SerializeField] private ParticleSystem tireSmokeLeft;
        [SerializeField] private ParticleSystem tireSmokeRight;
        [SerializeField] private ParticleSystem exhaustFire;
        [SerializeField] private ParticleSystem nitroGlow;

        [Header("Настройки")]
        [SerializeField] private float smokeThreshold = 0.5f;
        [SerializeField] private float nitroDuration = 3f;

        [Header("Ссылки")]
        [SerializeField] private Physics.CarPhysics carPhysics;

        private bool isNitroActive;
        private float nitroTimer;

        private void Start()
        {
            Logger.I("CarEffects initialized");

            if (carPhysics == null)
            {
                carPhysics = GetComponent<Physics.CarPhysics>();
            }

            FindParticleSystems();
        }

        private void Update()
        {
            if (carPhysics == null) return;

            UpdateTireSmoke();
            UpdateExhaustFire();
            UpdateNitroEffect();
        }

        #region Setup

        private void FindParticleSystems()
        {
            // Попытка найти системы частиц в дочерних объектах
            if (tireSmokeLeft == null)
                tireSmokeLeft = GetComponentInChildren<ParticleSystem>();

            if (tireSmokeRight == null)
            {
                var systems = GetComponentsInChildren<ParticleSystem>();
                if (systems.Length > 1)
                    tireSmokeRight = systems[1];
            }
        }

        #endregion

        #region Effects

        private void UpdateTireSmoke()
        {
            bool isGasPressed = UnityEngine.Input.GetKey(KeyCode.W) || UnityEngine.Input.GetKey(KeyCode.UpArrow);
            float speed = carPhysics.GetSpeed();

            // Дым при пробуксовке
            if (isGasPressed && speed < 20f)
            {
                EmitTireSmoke();
            }
            else
            {
                StopTireSmoke();
            }
        }

        private void UpdateExhaustFire()
        {
            if (exhaustFire == null) return;

            float rpm = carPhysics.GetRpm();

            // Огонь из выхлопа при высоких оборотах
            if (rpm > 6000f)
            {
                if (!exhaustFire.isPlaying)
                    exhaustFire.Play();

                var emission = exhaustFire.emission;
                emission.rateOverTime = Mathf.Lerp(5, 20, (rpm - 6000) / 2000);
            }
            else
            {
                if (exhaustFire.isPlaying)
                    exhaustFire.Stop();
            }
        }

        private void UpdateNitroEffect()
        {
            bool isNitroPressed = UnityEngine.Input.GetKey(KeyCode.LeftShift) || UnityEngine.Input.GetKey(KeyCode.N);

            if (isNitroPressed && carPhysics.GetNitroAmount() > 0)
            {
                ActivateNitro();
            }
            else
            {
                DeactivateNitro();
            }
        }

        #endregion

        #region Control

        private void EmitTireSmoke()
        {
            if (tireSmokeLeft != null && !tireSmokeLeft.isPlaying)
                tireSmokeLeft.Play();

            if (tireSmokeRight != null && !tireSmokeRight.isPlaying)
                tireSmokeRight.Play();
        }

        private void StopTireSmoke()
        {
            if (tireSmokeLeft != null && tireSmokeLeft.isPlaying)
                tireSmokeLeft.Stop();

            if (tireSmokeRight != null && tireSmokeRight.isPlaying)
                tireSmokeRight.Stop();
        }

        private void ActivateNitro()
        {
            if (isNitroActive) return;

            isNitroActive = true;
            nitroTimer = nitroDuration;

            if (nitroGlow != null)
            {
                nitroGlow.Play();
            }

            Logger.D("Nitro activated!");
        }

        private void DeactivateNitro()
        {
            if (!isNitroActive) return;

            isNitroActive = false;

            if (nitroGlow != null && nitroGlow.isPlaying)
            {
                nitroGlow.Stop();
            }

            Logger.D("Nitro deactivated");
        }

        #endregion

        #region Public Methods

        public void PlayShiftEffect()
        {
            // Искры при переключении передач (для турбо)
            if (exhaustFire != null)
            {
                exhaustFire.Emit(10);
            }
        }

        public void ResetEffects()
        {
            StopTireSmoke();

            if (exhaustFire != null && exhaustFire.isPlaying)
                exhaustFire.Stop();

            if (nitroGlow != null && nitroGlow.isPlaying)
                nitroGlow.Stop();

            isNitroActive = false;
        }

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(10, 860, 300, 100));
            GUILayout.Label("=== CAR EFFECTS ===");
            GUILayout.Label($"Tire Smoke: {(tireSmokeLeft != null && tireSmokeLeft.isPlaying ? "ON" : "OFF")}");
            GUILayout.Label($"Nitro: {(isNitroActive ? "ACTIVE" : "READY")}");
            GUILayout.EndArea();
        }

        #endregion
    }
}
