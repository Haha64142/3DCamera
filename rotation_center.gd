extends Marker3D

const RAY_LENGTH := 100.0
const ZOOM_FACTOR := 1.1

var raycast_result: Dictionary
var update_raycast := false

var pan_scale: float
var viewport_height: float

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
		if raycast_result:
			print(raycast_result.position)
			axis.position = raycast_result.position
		else:
			print("none")
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
				viewport_height = get_viewport().get_visible_rect().size.y
				pan_scale = camera.size / viewport_height
				translate_object_local(Vector3(
						pan_scale * -event.screen_relative.x,
						pan_scale * event.screen_relative.y,
						0
				))
				
			MOUSE_BUTTON_RIGHT:
				if raycast_result:
					var camera_position = camera.global_position
					position = raycast_result.position
					camera.global_position = camera_position
				rotation.y -= event.screen_relative.x / 100
				rotation.x -= event.screen_relative.y / 100
			
			_:
				update_raycast = true

func zoom(factor: float) -> void:
	var mouse := get_viewport().get_mouse_position()
	var viewport_size := get_viewport().get_visible_rect().size
	var mouse_offset := mouse - viewport_size / 2.0
	mouse_offset *= 2
	print(mouse_offset)
	var normalized := mouse_offset / viewport_size
	print(normalized)
	ray_pointer.position = camera.project_ray_origin(get_viewport().get_mouse_position())
	ray_pointer.rotation = camera.global_rotation
	camera.size *= factor
	var camera_scale := factor - 1
	camera.h_offset += -normalized.x * camera.size * camera_scale
	camera.v_offset += normalized.y * camera.size * camera_scale
