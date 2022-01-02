extends Container
class_name Column

#### ACCESSORS ####

func is_class(value: String): return value == "Column" or .is_class(value)
func get_class() -> String: return "Column"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("resized", self, "_on_resized")


#### VIRTUALS ####



#### LOGIC ####

func sort_children() -> void:
	pass


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_resized() -> void:
	sort_children()
