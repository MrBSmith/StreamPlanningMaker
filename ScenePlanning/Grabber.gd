extends Control
class_name Grabber

var hovered : bool = false setget set_hovered, is_hovered
var clicked : bool = false setget set_clicked, is_clicked

signal clicked_changed(clicked)

#### ACCESSORS ####

func is_class(value: String): return value == "Grabber" or .is_class(value)
func get_class() -> String: return "Grabber"

func set_hovered(value: bool) -> void: hovered = value
func is_hovered() -> bool: return hovered

func set_clicked(value: bool) -> void: 
	if value != clicked:
		clicked = value
		emit_signal("clicked_changed", clicked)
func is_clicked() -> bool: return clicked

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("mouse_entered", self, "_on_mouse_entered")
	__ = connect("mouse_exited", self, "_on_mouse_exited")
	
	set_modulate(Color.transparent)



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		if is_hovered():
			set_clicked(event.is_pressed())


#### SIGNAL RESPONSES ####

func _on_mouse_entered() -> void:
	set_hovered(true)
	set_modulate(Color.white)


func _on_mouse_exited() -> void:
	set_hovered(false)
	set_modulate(Color.transparent)
