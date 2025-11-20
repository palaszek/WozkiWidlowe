using UnityEngine;
using UnityEngine.InputSystem; // <-- nowy Input System

[RequireComponent(typeof(CharacterController))]
public class FirstPersonWalker_InputSystem : MonoBehaviour
{
    [Header("Movement")]
    public float walkSpeed = 4f;
    public float runSpeed = 7f;
    public float gravity = -9.81f;

    [Header("Mouse Look")]
    public Transform cameraTransform;
    public float mouseSensitivity = 120f; // stopnie/sek na jednostkê delta
    public float minPitch = -80f;
    public float maxPitch = 80f;

    private CharacterController controller;
    private float pitch = 0f;
    private Vector3 velocity;

    // Input Actions (tworzymy w kodzie, bez assetu .inputactions)
    private InputAction moveAction;
    private InputAction lookAction;
    private InputAction runAction;

    void Awake()
    {
        controller = GetComponent<CharacterController>();

        // --- MOVE: 2DVector z WASD + lewy analog pada ---
        moveAction = new InputAction("Move", InputActionType.Value);
        moveAction.AddBinding("<Gamepad>/leftStick");

        var wasd = moveAction.AddCompositeBinding("2DVector");
        wasd.With("Up", "<Keyboard>/w");
        wasd.With("Down", "<Keyboard>/s");
        wasd.With("Left", "<Keyboard>/a");
        wasd.With("Right", "<Keyboard>/d");

        // --- LOOK: delta myszy / rightStick pada ---
        lookAction = new InputAction("Look", InputActionType.Value);
        lookAction.AddBinding("<Mouse>/delta");
        lookAction.AddBinding("<Gamepad>/rightStick"); // opcjonalnie pad

        // --- RUN (sprint) ---
        runAction = new InputAction("Run", InputActionType.Button, "<Keyboard>/leftShift");
    }

    void OnEnable()
    {
        moveAction.Enable();
        lookAction.Enable();
        runAction.Enable();
    }

    void OnDisable()
    {
        moveAction.Disable();
        lookAction.Disable();
        runAction.Disable();
    }

    void Start()
    {
        // Blokada kursora
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        if (cameraTransform == null)
        {
            Camera cam = GetComponentInChildren<Camera>();
            if (cam) cameraTransform = cam.transform;
        }
    }

    void Update()
    {
        HandleMouseLook();
        HandleMovement();
        ApplyGravity();
    }

    void HandleMouseLook()
    {
        Vector2 look = lookAction.ReadValue<Vector2>(); // delta myszy / prawa ga³ka
        // delta myszy jest w pikselach na klatkê; skalujemy Time.deltaTime aby czu³oœæ by³a niezale¿na od FPS
        float mouseX = look.x * mouseSensitivity * Time.deltaTime;
        float mouseY = look.y * mouseSensitivity * Time.deltaTime;

        // obrót poziomy ca³ego gracza (yaw)
        transform.Rotate(Vector3.up * mouseX);

        // obrót pionowy kamery (pitch)
        pitch -= mouseY;
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);
        if (cameraTransform != null)
            cameraTransform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    void HandleMovement()
    {
        Vector2 input = moveAction.ReadValue<Vector2>(); // X=AD, Y=WS
        Vector3 move = (transform.right * input.x + transform.forward * input.y).normalized;

        float speed = runAction.IsPressed() ? runSpeed : walkSpeed;
        controller.Move(move * speed * Time.deltaTime);
    }

    void ApplyGravity()
    {
        if (controller.isGrounded && velocity.y < 0f)
            velocity.y = -2f; // delikatny docisk

        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
    }
}
