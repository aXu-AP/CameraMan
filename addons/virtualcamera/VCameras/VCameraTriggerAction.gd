tool
extends Node

class_name VCameraTriggerAction

enum Action {
	NOTHING,
	ENABLE,
	DISABLE,
	SET_PRIORITY,
	ADD_TO_GROUP,
	REMOVE_FROM_GROUP
}

var target_vcamera : NodePath
var filter_objects_by_group : String

var on_enter_action : int = Action.ENABLE setget set_on_enter_action
func set_on_enter_action(value : int) -> void:
	on_enter_action = value
	property_list_changed_notify()

var on_enter_priority : int = 0
var on_enter_group : String = ""

var on_exit_action : int = Action.DISABLE setget set_on_exit_action
func set_on_exit_action(value : int) -> void:
	on_exit_action = value
	property_list_changed_notify()

var on_exit_priority : int = 0
var on_exit_group : String = ""

var _overlapping_count : int = 0 setget _set_overlapping_count

func _ready() -> void:
	if get_parent() is Area and not Engine.editor_hint:
		get_parent().connect("area_entered", self, "_on_entered")
		get_parent().connect("body_entered", self, "_on_entered")
		get_parent().connect("area_exited", self, "_on_exited")
		get_parent().connect("body_exited", self, "_on_exited")

func _on_entered(area) -> void:
	if filter_objects_by_group and not area.is_in_group(filter_objects_by_group):
		return
	self._overlapping_count += 1

func _on_exited(area) -> void:
	if filter_objects_by_group and not area.is_in_group(filter_objects_by_group):
		return
	self._overlapping_count -= 1

func _set_overlapping_count(value : int):
	if _overlapping_count == 0 and value > 0:
		execute(on_enter_action, on_enter_priority, on_enter_group)
	elif _overlapping_count > 0 and value == 0:
		execute(on_exit_action, on_exit_priority, on_exit_group)
	
	_overlapping_count = value

func execute(action : int, priority : int, group : String) -> void:
	var vcamera : VCamera = get_node_or_null(self.target_vcamera) as VCamera
	if vcamera:
		match action:
			Action.ENABLE:
				vcamera.enabled = true
			Action.DISABLE:
				vcamera.enabled = false
			Action.SET_PRIORITY:
				vcamera.priority = priority
			Action.ADD_TO_GROUP:
				vcamera.add_to_group(group)
			Action.REMOVE_FROM_GROUP:
				vcamera.remove_from_group(group)

func _get_property_list() -> Array:
	var properties : Array = []
	
	properties.append({
		name = "target_vcamera",
		type = TYPE_NODE_PATH
	})
	
	properties.append({
		name = "filter_objects_by_group",
		type = TYPE_STRING
	})
	
	var action_keys : String = ""
	for key in Action.keys():
		action_keys += key.capitalize() + ","
	action_keys = action_keys.rstrip(",")
	
	properties.append({
		name = "On Enter",
		type = TYPE_NIL,
		hint_string = "on_enter_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	properties.append({
		name = "on_enter_action",
		hint = PROPERTY_HINT_ENUM,
		hint_string = action_keys,
		type = TYPE_INT
	})
	
	if on_enter_action == Action.SET_PRIORITY:
		properties.append({
			name = "on_enter_priority",
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1024",
			type = TYPE_INT
		})
	
	if on_enter_action == Action.ADD_TO_GROUP or on_enter_action == Action.REMOVE_FROM_GROUP:
		properties.append({
			name = "on_enter_group",
			type = TYPE_STRING
		})
	
	properties.append({
		name = "On Exit",
		type = TYPE_NIL,
		hint_string = "on_exit_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	properties.append({
		name = "on_exit_action",
		hint = PROPERTY_HINT_ENUM,
		hint_string = action_keys,
		type = TYPE_INT
	})
	
	if on_exit_action == Action.SET_PRIORITY:
		properties.append({
			name = "on_exit_priority",
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,1024",
			type = TYPE_INT
		})
	
	if on_exit_action == Action.ADD_TO_GROUP or on_exit_action == Action.REMOVE_FROM_GROUP:
		properties.append({
			name = "on_exit_group",
			type = TYPE_STRING
		})
	
	return properties

func _get_configuration_warning():
	if get_parent() is Area:
		return ""
	else:
		return "VCameraTriggerAction has to be child of Area to be usable.\n\nAction choosen on enter will be executed when first area/body enters parent Area.\nAction choosen on exit will be executed when last area/body leaves parent Area."
