extends Control
class_name StreamPanel

onready var top_grabber = $TopGrabber
onready var bottom_grabber = $BottomGrabber

var move_grabber_dragged : bool = false
var top_grabber_dragged : bool = false
var bottom_grabber_dragged : bool = false

var grab_position := Vector2.ZERO
var initial_panel_position := Vector2.ZERO
var initial_panel_global_position := Vector2.ZERO
var initial_panel_size := Vector2.ZERO
var mouse_pos := Vector2.ZERO
var container_size := Vector2.ZERO
var container_pos := Vector2.ZERO

var column_shift : bool = false
var ghost_mode : bool = false setget set_ghost_mode

var is_ready := false

signal column_shift_query()
signal ghost_mode_changed(value)

#### ACCESSORS ####

func is_class(value: String): return value == "StreamPanel" or .is_class(value)
func get_class() -> String: return "StreamPanel"

func set_ghost_mode(value: bool) -> void:
	if value != ghost_mode:
		ghost_mode = value
		emit_signal("ghost_mode_changed", ghost_mode)

#### BUILT-IN ####


func _ready() -> void:
	var __ = connect("ghost_mode_changed", self, "_on_ghost_mode_changed")
	
	is_ready = true


func _process(_delta: float) -> void:
	if !top_grabber_dragged and !bottom_grabber_dragged and !move_grabber_dragged and !ghost_mode:
		return

	var global_pos = get_global_position()
	container_size = get_parent().get_size()
	container_pos = get_parent().get_global_position()
	var initial_bottom = initial_panel_global_position.y + initial_panel_size.y
	var time_slot_size = get_parent().rect_size.y / GLOBAL.nb_time_slot
	
	mouse_pos = get_global_mouse_position()
	
	if ghost_mode:
		_drag()
	else:
		set_ghost_mode(_is_dragged_outside_column())
		
		# Handles resizing using the top grabber
		if top_grabber_dragged:
			rect_global_position.y = clamp(stepify(mouse_pos.y, time_slot_size), 
									container_pos.y, initial_bottom - time_slot_size)
			rect_size.y = clamp(initial_bottom - rect_global_position.y, time_slot_size, container_size.y)
		
		# Handles resizing using the bottom grabber
		elif bottom_grabber_dragged:
			var v_mouse_dist = clamp(mouse_pos.y - global_pos.y, 0.0, INF)
			rect_size.y = clamp(stepify(v_mouse_dist, time_slot_size), time_slot_size, container_size.y)
		
		# Handles moving the panel verticaly
		elif move_grabber_dragged:
			var grab_offset = grab_position - initial_panel_global_position
			var container_bottom_right = container_pos + container_size
			
			rect_global_position.y = clamp(stepify(mouse_pos.y - grab_offset.y, time_slot_size) + container_pos.y, 
							container_pos.y, container_bottom_right.y - rect_size.y)


#### VIRTUALS ####



#### LOGIC ####

func _update_grab_inital_values() -> void:
	initial_panel_global_position = get_global_position()
	initial_panel_position = get_position()
	initial_panel_size = rect_size
	grab_position = get_global_mouse_position()


func _is_dragged_outside_column() -> bool:
	return mouse_pos.x > container_pos.x + container_size.x or mouse_pos.x < container_pos.x


func _drag() -> void:
	var viewport_rect = get_tree().get_root().get_visible_rect()
	if !viewport_rect.has_point(mouse_pos):
		_undrag()
	else:
		var grab_offset = grab_position - initial_panel_global_position
		set_global_position(mouse_pos - grab_offset)


func _undrag() -> void:
	emit_signal("column_shift_query", self)
	ghost_mode = false
	move_grabber_dragged = false


#### INPUTS ####

func _gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("left_click") && ghost_mode:
		_undrag()


#### SIGNAL RESPONSES ####


func _on_TopGrabber_clicked_changed(clicked: bool) -> void:
	if ghost_mode:
		return
	top_grabber_dragged = clicked
	_update_grab_inital_values()


func _on_BottomGrabber_clicked_changed(clicked: bool) -> void:
	if ghost_mode:
		return
	bottom_grabber_dragged = clicked
	_update_grab_inital_values()


func _on_MoveGrabber_clicked_changed(clicked: bool) -> void:
	if !ghost_mode:
		move_grabber_dragged = clicked
		
		if clicked:
			_update_grab_inital_values()


func _on_ghost_mode_changed(ghost: bool) -> void:
	var mod = Color.white if !ghost else Color(1.0, 1.0, 1.0, 0.3)
	set_modulate(mod)


func _on_EVENTS_mouse_exited_window() -> void:
	if ghost_mode:
		_undrag()
