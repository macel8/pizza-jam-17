extends CharacterBody3D

@export_range(0.001, 0.1, 0.001) var mouse_sensitivity = 0.01

@onready var camera: Camera3D = $Camera

const SPEED = 10.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton:
		if event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
		self.rotation.y -= event.relative.x * mouse_sensitivity
		self.rotation.y = wrapf(rotation.y, 0, TAU)
		#TODO: change self to camera here
		self.rotation.x -= event.relative.y * mouse_sensitivity
		self.rotation.x = clamp(self.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_cancel"):
	#	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_torwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
		velocity.z = direction.z * SPEED
		if Input.is_action_pressed("sprint"):
			velocity *= 3
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
