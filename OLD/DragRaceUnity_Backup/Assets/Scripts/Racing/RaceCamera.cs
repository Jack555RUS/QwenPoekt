using UnityEngine;
using ProbMenu.Core;
using ProbMenu.Physics;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Racing
{
    /// <summary>
    /// Камера слежения за автомобилем
    /// Плавное слежение, несколько режимов
    /// </summary>
    public class RaceCamera : MonoBehaviour
    {
        [Header("Цель")]
        [SerializeField] private Transform target;
        [SerializeField] private CarPhysics playerCar;

        [Header("Позиция камеры")]
        [SerializeField] private Vector3 offset = new Vector3(0, 5, -10);
        [SerializeField] private float smoothSpeed = 5f;

        [Header("Режимы")]
        [SerializeField] private CameraMode cameraMode = CameraMode.Follow;

        [Header("Настройки")]
        [SerializeField] private float minFOV = 60f;
        [SerializeField] private float maxFOV = 90f;
        [SerializeField] private float fovSpeedThreshold = 100f; // км/ч

        [Header("Вращение")]
        [SerializeField] private float rotationSmoothness = 3f;
        [SerializeField] private float maxRotationAngle = 10f;

        private Camera _camera;
        private float defaultFOV;
        private Quaternion targetRotation;

        private void Start()
        {
            _camera = GetComponent<Camera>();
            defaultFOV = _camera.fieldOfView;

            Logger.AssertNotNull(target, "Camera target");

            if (target == null && playerCar != null)
            {
                target = playerCar.transform;
            }

            Logger.I("RaceCamera initialized");
        }

        private void LateUpdate()
        {
            if (target == null) return;

            switch (cameraMode)
            {
                case CameraMode.Follow:
                    FollowCamera();
                    break;
                case CameraMode.Side:
                    SideCamera();
                    break;
                case CameraMode.Hood:
                    HoodCamera();
                    break;
            }

            UpdateFOV();
        }

        #region Camera Modes

        private void FollowCamera()
        {
            // Плавное слежение сзади
            Vector3 targetPosition = target.position + target.rotation * offset;
            transform.position = Vector3.Lerp(transform.position, targetPosition, smoothSpeed * Time.deltaTime);

            // Плавный поворот за машиной
            targetRotation = Quaternion.LookRotation(target.position - transform.position);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSmoothness * Time.deltaTime);
        }

        private void SideCamera()
        {
            // Вид сбоку (для драг-рейсинга)
            Vector3 sideOffset = new Vector3(-15, 3, 0);
            Vector3 targetPosition = target.position + sideOffset;

            transform.position = Vector3.Lerp(transform.position, targetPosition, smoothSpeed * Time.deltaTime);
            transform.LookAt(target.position + Vector3.up * 2);
        }

        private void HoodCamera()
        {
            // Вид из кабины
            Vector3 hoodOffset = new Vector3(0, 1.5f, 2);
            transform.position = target.position + target.rotation * hoodOffset;
            transform.rotation = target.rotation;
        }

        #endregion

        #region FOV Dynamics

        private void UpdateFOV()
        {
            if (playerCar == null) return;

            float speed = playerCar.GetSpeedKmh();
            float fovMultiplier = Mathf.Clamp01(speed / fovSpeedThreshold);

            float targetFOV = Mathf.Lerp(minFOV, maxFOV, fovMultiplier);
            _camera.fieldOfView = Mathf.Lerp(_camera.fieldOfView, targetFOV, 2f * Time.deltaTime);
        }

        #endregion

        #region Public Methods

        public void SetCameraMode(CameraMode mode)
        {
            cameraMode = mode;
            Logger.I($"Camera mode: {mode}");
        }

        public void SetTarget(Transform newTarget)
        {
            target = newTarget;
            Logger.AssertNotNull(target, "Camera target");
        }

        public void ResetCamera()
        {
            if (target == null) return;

            transform.position = target.position + target.rotation * offset;
            transform.LookAt(target.position);
            _camera.fieldOfView = defaultFOV;
        }

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(10, 640, 300, 100));
            GUILayout.Label("=== CAMERA ===");
            GUILayout.Label($"Mode: {cameraMode}");
            GUILayout.Label($"FOV: {_camera.fieldOfView:F1}");
            GUILayout.EndArea();
        }

        #endregion
    }

    /// <summary>
    /// Режимы камеры
    /// </summary>
    public enum CameraMode
    {
        Follow,     // Слежение сзади
        Side,       // Вид сбоку
        Hood,       // Из кабины
        Fixed       // Статичная
    }
}
