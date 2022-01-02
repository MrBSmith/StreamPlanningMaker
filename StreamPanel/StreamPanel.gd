extends Control
class_name StreamPanel

onready var top_grabber = $TopGrabber
onready var bottom_grabber = $BottomGrabber
onready var title = $VBoxContainer/Title
onready var subtitle = $VBoxContainer/Subtitle

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
var layout : PanelLayout = null setget set_layout, get_layout

var is_ready := false

signal column_shift_query()
signal ghost_mode_changed(value)
signal layout_changed

#### ACCESSORS ####

func is_class(value: String): return value == "StreamPanel" or .is_class(value)
func get_class() -> String: return "StreamPanel"

func set_ghost_mode(value: bool) -> void:
	if value != ghost_mode:
		ghost_mode = value
		emit_signal("ghost_mode_changed", ghost_mode)

func set_layout(value: PanelLayout) -> void:
	if layout != value:
		layout = value
		emit_signal("layout_changed")
func get_layout() -> PanelLayout: return layout

#### BUILT-IN ####


func _ready() -> void:
	var __ = connect("ghost_mode_changed", self, "_on_ghost_mode_changed")
	__ = connect("layout_changed", self, "_on_layout_changed")
	__ = title.connect("text_entered", self, "_on_text_entered")
	__ = subtitle.connect("text_entered", self, "_on_text_entered")
	
	is_ready = true


func _process(_delta: float) -> void:
	if !top_grabber_dragged and !bottom_grabber_dragged and !move_grabber_dragged and !ghost_mode:
		return

	container_size = get_parent().get_size()
	container_pos = get_parent().get_global_position()
	var initial_bottom = initial_panel_global_position.y + initial_panel_size.y
	var time_slot_size = get_parent().rect_size.y / GLOBAL.nb_time_slot
	
	mouse_pos = get_global_mouse_position()
	
	if ghost_mode:
		_drag()
	else:
		set_ghost_mode(_is_dragged_outside_column())
		
		var global_pos = get_global_position()
		var size = get_size()
		
		# Handles resizing using the top grabber
		if top_grabber_dragged:
			global_pos.y = clamp(stepify(mouse_pos.y, time_slot_size) + container_pos.y, 
									container_pos.y, initial_bottom - time_slot_size)
			size.y = clamp(stepify(initial_bottom - global_pos.y, time_slot_size), time_slot_size, container_size.y)
		
		# Handles resizing using the bottom grabber
		elif bottom_grabber_dragged:
			var v_mouse_dist = clamp(mouse_pos.y - global_pos.y, 0.0, INF)
			size.y = clamp(stepify(v_mouse_dist, time_slot_size), time_slot_size, container_size.y - rect_position.y)
		
		# Handles moving the panel verticaly
		elif move_grabber_dragged:
			var grab_offset = grab_position - initial_panel_global_position
			var container_bottom_right = container_pos + container_size
			
			global_pos.y = clamp(stepify(mouse_pos.y - grab_offset.y, time_slot_size) + container_pos.y, 
							container_pos.y, container_bottom_right.y - size.y)
		
		else:
			return
		
		var rect = Rect2(global_pos, size)
		if !_overlaps_another_panel(rect):
			set_global_position(global_pos)
			set_size(size)


#### VIRTUALS ####



#### LOGIC ####

func _find_layout() -> PanelLayout:
	var max_score = 0
	var best_fit_layout : PanelLayout = null
	
	for panel_layout in GLOBAL.panel_layouts_array:
		var score = 0
		for keyword in panel_layout.keywords:
			if keyword.is_subsequence_ofi(title.text) or keyword.is_subsequence_ofi(title.text.replace(" ", "")):
				score += 1
			
			if keyword.is_subsequence_ofi(subtitle.text) or keyword.is_subsequence_ofi(subtitle.text.replace(" ", "")):
				score += 1
			
		if score > max_score:
			best_fit_layout = panel_layout
			max_score = score
	
	return best_fit_layout


func _overlaps_another_panel(rect: Rect2) -> bool:
	for panel in get_tree().get_nodes_in_group("Panel"):
		if panel == self: continue
		var panel_rect = Rect2(panel.get_global_position(), panel.get_size())
		
		if panel_rect.intersects(rect):
			return true
	return false


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


func _on_layout_changed() -> void:
	$BackgroundColor.set_frame_color(layout.background_color)
	$BackgroundImage.set_texture(layout.background_image)
	
	if layout.border_image != null:
		$Border.set_texture(layout.border_image)
		$Border.set_modulate(layout.border_color)
		
		for i in range(4):
			var size = layout.border_image.get_size().x if i in [0, 2] else layout.border_image.get_size().y
			$Border.set_patch_margin(i, size / 3)


func _on_text_entered(_text: String) -> void:
	set_layout(_find_layout())
