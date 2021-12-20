extends Control
class_name StreamPanel

onready var top_grabber = $TopGrabber
onready var bottom_grabber = $BottomGrabber

var move_grabber_dragged : bool = false
var top_grabber_dragged : bool = false
var bottom_grabber_dragged : bool = false

var grab_position := Vector2.ZERO
var initial_panel_position := Vector2.ZERO
var initial_panel_size := Vector2.ZERO

#### ACCESSORS ####

func is_class(value: String): return value == "StreamPanel" or .is_class(value)
func get_class() -> String: return "StreamPanel"


#### BUILT-IN ####

func _process(_delta: float) -> void:
	if !top_grabber_dragged and !bottom_grabber_dragged and !move_grabber_dragged:
		return
	
	var global_pos = get_global_position()
	var mouse_pos = get_global_mouse_position()
	var container_size = get_parent().get_size()
	var container_pos = get_parent().get_global_position()
	var initial_bottom = initial_panel_position.y + initial_panel_size.y
	
	if top_grabber_dragged:
		rect_global_position.y = clamp(stepify(mouse_pos.y, 50.0), container_pos.y, initial_bottom - 50.0)
		rect_size.y = clamp(initial_bottom - rect_global_position.y, 50.0, container_size.y)
	
	elif bottom_grabber_dragged:
		var v_mouse_dist = clamp(mouse_pos.y - global_pos.y, 0.0, INF)
		rect_size.y = clamp(stepify(v_mouse_dist, 50.0), 50.0, container_size.y)
	
	elif move_grabber_dragged:
		var grab_offset = grab_position.y - initial_panel_position.y
		var container_bottom = container_pos.y + container_size.y
		rect_global_position.y = clamp(stepify(mouse_pos.y - grab_offset, 50.0), 
									container_pos.y, container_bottom - rect_size.y)


#### VIRTUALS ####



#### LOGIC ####

func _update_grab_inital_values() -> void:
	initial_panel_position = get_global_position()
	initial_panel_size = rect_size
	grab_position = get_global_mouse_position()


#### INPUTS ####



#### SIGNAL RESPONSES ####



func _on_TopGrabber_clicked_changed(clicked: bool) -> void:
	top_grabber_dragged = clicked
	_update_grab_inital_values()


func _on_BottomGrabber_clicked_changed(clicked: bool) -> void:
	bottom_grabber_dragged = clicked
	_update_grab_inital_values()


func _on_MoveGrabber_clicked_changed(clicked: bool) -> void:
	move_grabber_dragged = clicked
	_update_grab_inital_values()
