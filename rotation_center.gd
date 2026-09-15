extends Marker3D

const RAY_LENGTH := 100.0
const ZOOM_FACTOR := 1.1

var raycast_result: Dictionary
var update_raycast := false

var mouse_button_handler := MouseButtonHandler.new()

@onready var camera = $Camera3D
@onready var axis = $Axis
@onready var ray_pointer = $RayPointer

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if update_raycast:
		var from: Vector3 = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to: Vector3 = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
		var query := PhysicsRayQueryParameters3D.create(from, to)
		raycast_result = get_world_3d().direct_space_state.intersect_ray(query)
		print(raycast_result)
		#if raycast_result:
			#axis.position = raycast_result.position
		update_raycast = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		update_raycast = true
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			zoom(ZOOM_FACTOR)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			zoom(1/ZOOM_FACTOR)
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				mouse_button_handler.press(event.button_index)
			else:
				mouse_button_handler.release(event.button_index)
	
	if event is InputEventMouseMotion:
		match mouse_button_handler.get_active_button():
			MOUSE_BUTTON_MIDDLE:
				pan(event.relative)
				
			MOUSE_BUTTON_RIGHT:
				rotate_camera(event.screen_relative)
			
			_:
				update_raycast = true

func zoom(factor: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var viewport_size := get_viewport().get_visible_rect().size
	var mouse_offset_pixels := mouse_pos - viewport_size / 2.0
	var mouse_offset_meters: Vector2 = mouse_offset_pixels * camera.size / viewport_size.y
	var new_size = camera.size * factor
	if new_size <= 0.00001:
		return
	camera.size = new_size
	print(camera.size)
	var camera_scale := factor - 1
	translate_object_local(Vector3(
			-mouse_offset_meters.x * camera_scale,
			mouse_offset_meters.y * camera_scale,
			0
	))
	#ray_pointer.position = camera.project_ray_origin(mouse)
	#ray_pointer.rotation = camera.global_rotation


func pan(mouse_delta: Vector2) -> void:
	var pan_ratio: float = camera.size / get_viewport().get_visible_rect().size.y
	translate_object_local(Vector3(
			pan_ratio * -mouse_delta.x,
			pan_ratio * mouse_delta.y,
			0
	))

func rotate_camera(mouse_delta: Vector2) -> void:
	if raycast_result:
		var camera_position = camera.global_position
		position = raycast_result.position
		camera.global_position = camera_position
	rotation.y -= mouse_delta.x / 100
	rotation.x -= mouse_delta.y / 100
