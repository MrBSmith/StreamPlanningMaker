extends Control

var stream_panel_scene = preload("res://StreamPanel/StreamPanel.tscn")
var add_panel_button_scene = preload("res://ScenePlanning/AddPanelButton/AddPanelButton.tscn")

export var print_logs : bool = false

#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	_generate_add_panel_buttons()


#### VIRTUALS ####



#### LOGIC ####

func _panel_change_column(panel: StreamPanel, column: Column) -> void:
	var origin_column = panel.get_parent()
	
	if column == panel.get_parent():
		panel.ghost_mode = false
		panel.set_modulate(Color.white)
		panel.set_position(panel.initial_panel_position)
	
	else:
		var new_panel = panel.duplicate(7)
		
		_add_panel(new_panel, column, panel.initial_panel_position, panel.rect_size.y)
		panel.queue_free()
		
		yield(get_tree(), "idle_frame")
		_update_column_buttons(origin_column)
		_update_column_buttons(column)


func _add_panel(panel: StreamPanel, column: Column, dest_pos := Vector2.ZERO, height : float = 100.0) -> void:
	if !panel.is_connected("column_shift_query", self, "_on_StreamPanel_column_shift_query"):
		var __ = panel.connect("column_shift_query", self, "_on_StreamPanel_column_shift_query")
		__ = panel.connect("item_rect_changed", self, "_on_StreamPanel_item_rect_changed", [panel])
	
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
			_add_panel_button(column, Rect2(pos, Vector2(width, height)))


func _add_panel_button(column: Column, rect: Rect2) -> void:
	var add_panel_button = add_panel_button_scene.instance()
	column.add_child(add_panel_button)
	add_panel_button.set_size(rect.size)
	add_panel_button.set_position(rect.position)
	
	var __ = add_panel_button.connect("pressed", self, "_on_add_panel_button_pressed", [add_panel_button, column])


func _update_column_buttons(column: Column) -> void:
	var panels_array = _fetch_column_panels(column)
	var button_array = _fetch_column_buttons(column)
	
	# Remove useless buttons & resize hovered ones
	for panel in panels_array:
		var panel_rect = panel.get_rect()
		
		# Handles panel changing column (The signal resized is called when added in the tree)
		if panel_rect.position.x != 0.0:
			continue
		
		for button in button_array:
			var button_rect = button.get_rect()
			var intersects = panel_rect.intersects(button_rect)
			var inside = Utils.is_rect_inside_rect(panel_rect, button_rect)
			var same_rect = panel_rect.is_equal_approx(button_rect)
			
			if inside or same_rect:
				if print_logs: print("Destroyed a button: the button is contained in the panel")
				button.queue_free()
			
			elif intersects:
				var button_poly = Utils.rect2poly(button_rect)
				var panel_poly = Utils.rect2poly(panel_rect)
				var intersect_poly_array = Geometry.intersect_polygons_2d(button_poly, panel_poly)
				
				if intersect_poly_array.empty():
					continue
				
				var intersect_rect : Rect2 = Utils.poly2rect(intersect_poly_array[0])
				var button_dist = abs(button_rect.position.y - panel_rect.position.y)
				
				if intersect_rect.size.y <= 1.0:
					if button_dist <= 1:
						if print_logs: print("Destroyed a button: Intersect rect is too small")
						button.queue_free()
					else:
						continue
				
				else:
					button.set_position(intersect_rect.position)
					button.set_size(intersect_rect.size)
					
					if print_logs:
						print("button_rect: " + String(button_rect))
						print("panel_rect: " + String(panel_rect))
						print("intersect_rect: " + String(intersect_rect))
	
	var time_slot_height = column.rect_size.y / GLOBAL.nb_time_slot
	
	for i in range(GLOBAL.nb_time_slot):
		var slot_rect = Rect2(Vector2.DOWN * time_slot_height * i, 
							Vector2(column.rect_size.x, time_slot_height))
		
		if _is_time_slot_empty(slot_rect, column):
			_add_panel_button(column, slot_rect)


func _is_time_slot_empty(time_slot_rect: Rect2, column: Column) -> bool:
	for child in column.get_children():
		var child_rect = Rect2(child.get_position(), child.get_size())
		var encloses = child_rect.encloses(time_slot_rect)
		var same_rect = child_rect.is_equal_approx(time_slot_rect)
		
		if encloses or same_rect:
			return false
	return true


func _fetch_column_panels(column: Column) -> Array:
	var array := Array()
	for child in column.get_children():
		if child is StreamPanel:
			array.append(child)
	return array


func _fetch_column_buttons(column: Column) -> Array:
	var array := Array()
	for child in column.get_children():
		if child is Button:
			array.append(child)
	return array


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


func _on_StreamPanel_item_rect_changed(panel: StreamPanel) -> void:
	if panel.ghost_mode:
		return
	
	_update_column_buttons(panel.get_parent())
