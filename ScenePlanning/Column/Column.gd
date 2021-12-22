extends Control
class_name Column

var mouse_inside : bool = false setget , is_mouse_inside

#### ACCESSORS ####

func is_class(value: String): return value == "Column" or .is_class(value)
func get_class() -> String: return "Column"

func is_mouse_inside() -> bool: return mouse_inside

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("mouse_entered", self, "_on_mouse_entered")
	__ = connect("mouse_exited", self, "_on_mouse_exited")


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false

