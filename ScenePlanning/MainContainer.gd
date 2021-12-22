extends Control

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	pass

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


func _add_panel(panel: StreamPanel, column: Column, dest_pos:= Vector2.ZERO) -> void:
	if !panel.is_connected("column_shift_query", self, "_on_StreamPanel_column_shift_query"):
		var __ = panel.connect("column_shift_query", self, "_on_StreamPanel_column_shift_query", [panel])
	
	column.add_child(panel)
	
	panel.ghost_mode = false
	panel.set_modulate(Color.white)
	panel.set_position(dest_pos) 


func _find_hovered_column(pos: Vector2) -> Column:
	for column in $ColumnsManager.get_children():
		if not column is Column: continue
		var rect = column.get_rect()
		
		if rect.has_point(pos):
			return column
	return null


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
