tool
extends "res://addons/virtualcamera/TransformModifiers/UserInput/UserInput.gd"

class_name FpsCamera

export var positive_yaw_mapped_input : String
export var negative_yaw_mapped_input : String
export var positive_pitch_mapped_input : String
export var negative_pitch_mapped_input : String

export var mouse_input : bool = true
export var mouse_sensitivity : float = 0.25
export var rotation_speed : Vector2 = Vector2(1, 1)
export(float, 0.0, 1.0) var lerp_speed : float = 1.0

export(int, FLAGS, "X", "Y") var invert_axis = 0b10

onready var input_rotation : Vector2 = Vector2.ZERO

func _input(event : InputEvent):
	if mouse_input and event is InputEventMouseMotion:
		input_rotation.x -= event.relative.x * rotation_speed.x * mouse_sensitivity
		input_rotation.y -= event.relative.y * rotation_speed.y * mouse_sensitivity

func _physics_process(delta : float):
	if not Engine.editor_hint:
		var yaw_axis = 0.0
		if !negative_yaw_mapped_input.empty():
			yaw_axis -= Input.get_action_strength(negative_yaw_mapped_input)
		if !positive_yaw_mapped_input.empty():
			yaw_axis += Input.get_action_strength(positive_yaw_mapped_input)
		input_rotation.x += yaw_axis * rotation_speed.x * 5
		
		var pitch_axis = 0.0
		if !negative_pitch_mapped_input.empty():
			pitch_axis -= Input.get_action_strength(negative_pitch_mapped_input)
		if !positive_pitch_mapped_input.empty():
			pitch_axis += Input.get_action_strength(positive_pitch_mapped_input)
		input_rotation.y += pitch_axis * rotation_speed.y * 5
		
		input_rotation.x = wrapf(input_rotation.x, -180, 180)
		input_rotation.y = clamp(input_rotation.y, -90, 90)
		var rot_y = -input_rotation.x if invert_axis & 0b01 else input_rotation.x
		rotation_degrees.y = rad2deg(lerp_angle(deg2rad(rotation_degrees.x), deg2rad(rot_y), lerp_speed))
		var rot_x = -input_rotation.y if invert_axis & 0b10 else input_rotation.y
		rotation_degrees.x = lerp(rotation_degrees.y, rot_x, lerp_speed)
