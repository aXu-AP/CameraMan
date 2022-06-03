tool
extends "res://addons/virtualcamera/TransformModifiers/UserInput/UserInput.gd"
# Transform modifier for first person camera. Controllable via mouse or mapped inputs.
class_name FpsCamera

# Speed of rotation in degrees per second.
var rotation_speed : Vector2 = Vector2(90, 90)
# Smoothing value from 0 (extreme smoothing) to 1 (no smoothing).
var lerp_speed : float = 1.0
# Inverts X (yaw) or Y (pitch) rotation defined by bit mask.
# Bit 0b01: X
# Bit 0b10: Y
var invert_axes : int = 0b00

# Enables mouse to control rotation.
var mouse_enabled : bool = true
# How much modifier rotates. 100 pixels of mouse movement results in rotation_speed degrees of rotation.
var mouse_sensitivity : float = 1.0

# Action name from Input Map to rotate to right.
var mapped_input_yaw_positive : String
# Action name from Input Map to rotate to left.
var mapped_input_yaw_negative : String
# Action name from Input Map to rotate to up.
var mapped_input_pitch_positive : String
# Action name from Input Map to rotate to down.
var mapped_input_pitch_negative : String
# How much modifier rotates multiplied with rotation_speed.
var mapped_input_sensitivity : float = 1.0

# Optional Spatial node to rotate instead of itself. Handles X (yaw) rotation.
# Useful, if you want to rotate character root node. Settable in editor.
var instead_yaw_target_path : NodePath
# Optional Spatial node to rotate instead of itself. Handles Y (pitch) rotation.
# Useful, if you want to rotate character root node. Settable in editor.
var instead_pitch_target_path : NodePath

# Optional Spatial node to rotate instead of itself. Handles X (yaw) rotation.
# Useful, if you want to rotate character root node. Settable runtime.
var instead_yaw_target : Spatial
# Optional Spatial node to rotate instead of itself. Handles Y (pitch) rotation.
# Useful, if you want to rotate character root node. Settable runtime.
var instead_pitch_target : Spatial

var _input_rotation : Vector2 = Vector2.ZERO


func _ready() -> void:
	if instead_yaw_target_path:
		instead_yaw_target = get_node(instead_yaw_target_path)
	if instead_pitch_target_path:
		instead_pitch_target = get_node(instead_pitch_target_path)

func _input(event : InputEvent):
	if mouse_enabled and event is InputEventMouseMotion:
		_input_rotation.x -= event.relative.x * mouse_sensitivity / 100.0
		_input_rotation.y -= event.relative.y * mouse_sensitivity / 100.0

func _physics_process(delta : float):
	if not Engine.editor_hint:
		_input_rotation += Input.get_vector(mapped_input_yaw_positive, mapped_input_yaw_negative, mapped_input_pitch_negative, mapped_input_pitch_positive) * mapped_input_sensitivity * delta
		
		var factor : Vector2 = deg2rad(1) * rotation_speed # Note: do conversion twice to not make separate conversion from _input_rotation
		if invert_axes & 0b01:
			factor.x *= -1
		if invert_axes & 0b10:
			factor.y *= -1
		
		var make_rotation = Vector2.ZERO.linear_interpolate(_input_rotation * factor, lerp_speed)
		
		var target = instead_yaw_target if is_instance_valid(instead_yaw_target) else self
		target.rotation.y += make_rotation.x
		
		target = instead_pitch_target if is_instance_valid(instead_pitch_target) else self
		target.rotation.x = clamp(target.rotation.x + make_rotation.y, -TAU / 4, TAU / 4)
		
		# If lerped, relay rest of the movement to the next frame (otherwise results in zero).
		_input_rotation -= make_rotation / factor


func _get_property_list() -> Array:
	var gen := preload("res://addons/virtualcamera/Helpers/PropertyListGenerator.gd").new(self)
	
	gen.append("rotation_speed")
	gen.append_number_range("lerp_speed", 0, 1)
	
	gen.append("invert_axes", PROPERTY_HINT_FLAGS, "X,Y")
	
	gen.append_category("mouse")
	gen.append("mouse_enabled")
	gen.append("mouse_sensitivity")
	
	gen.append_category("mapped_input")
	gen.append("mapped_input_yaw_positive")
	gen.append("mapped_input_yaw_negative")
	gen.append("mapped_input_pitch_positive")
	gen.append("mapped_input_pitch_negative")
	gen.append("mapped_input_sensitivity")
	
	gen.append_category("instead", "Rotate Other Instead")
	gen.append("instead_yaw_target_path")
	gen.append("instead_pitch_target_path")
	return gen.properties
