extends Node

export var nb_time_slot : int = 7
export var layout_dir_path = 'res://StreamPanel/PanelLayout/Layouts/'

var panel_layouts_array = []


#### ACCESSORS ####



#### BUILT-IN ####

func _ready() -> void:
	_load_layouts()


#### VIRTUALS ####



#### LOGIC ####

func _load_layouts() -> void:
	$FileFinder.find_all_files(layout_dir_path)
	panel_layouts_array = []
	
	for file_path in $FileFinder.target_array:
		panel_layouts_array.append(load(file_path))


#### INPUTS ####



#### SIGNAL RESPONSES ####
