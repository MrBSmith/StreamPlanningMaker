extends Control

var stream_panel_scene = preload("res://ScenePlanning/StreamPanel.tscn")
var add_panel_button_scene = preload("res://ScenePlanning/AddPanelButton/AddPanelButton.tscn")

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	_generate_add_panel_buttons()


#### VIRTUALS ####



#### LOGIC ####

func _panel_change_column(panel: StreamPanel, column: Column) -> void:
	if column == panel.get_parent():
		panel.ghost_mode = false
		panel.set_modulate(Color.white)
		panel.set_position(panel.initial_panel_position)
	else:
		var new_panel = panel.duplicate(7)
		
		_add_panel(new_panel, column, panel.initial_panel_position)
		panel.queue_free()


func _add_panel(panel: StreamPanel, column: Column, dest_pos := Vector2.ZERO, height : float = 100.0) -> void:
	if !panel.is_connected("column_shift_query", self, "_on_StreamPanel_column_shift_query"):
		var __ = panel.connect("column_shift_query", self, "_on_StreamPanel_column_shift_query")
	
	column.add_child(panel)
	
	panel.ghost_mode = false
	panel.set_modulate(Color.white)
	panel.set_position(dest_pos) 
	panel.set_size(Vector2(column.rect_size.x, height))


func _find_hovered_column(pos: Vector2) -> Column:
	for column in $ColumnsManager.get_children():
		if not column is Column: continue
		var rect = column.get_rect()
		
		if rect.has_point(pos):
			return column
	return null


func _generate_add_panel_buttons() -> void:
	for column in $ColumnsManager.get_children():
		for i in range(GLOBAL.nb_time_slot):
			var width = column.rect_size.x 
			var height = column.rect_size.y / GLOBAL.nb_time_slot
			var pos = Vector2.DOWN * height * i
			_add_panel_button(column, Vector2(width, height), pos)


func _add_panel_button(column: Column, size: Vector2, pos: Vector2) -> void:
	var add_panel_button = add_panel_button_scene.instance()
	column.add_child(add_panel_button)
	add_panel_button.set_size(size)
	add_panel_button.set_position(pos)
	
	var __ = add_panel_button.connect("pressed", self, "_on_add_panel_button_pressed", [add_panel_button, column])


#### INPUTS ####



#### SIGNAL RESPONSES ####



func _on_StreamPanel_column_shift_query(panel: StreamPanel) -> void:
	if !panel.ghost_mode:
		return
	
	var panel_pos = panel.get_global_position() + panel.rect_size / 2
	var column = _find_hovered_column(panel_pos)
	
	if column != null:
		_panel_change_column(panel, column)
	else:
		_panel_change_column(panel, panel.get_parent())


func _on_add_panel_button_pressed(button: Button, column: Control) -> void:
	var panel = stream_panel_scene.instance()
	_add_panel(panel, column, button.rect_position, button.rect_size.y)
	button.queue_free()
