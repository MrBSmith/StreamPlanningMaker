extends Resource
class_name PanelLayout

export var keywords = PoolStringArray()
export var background_color = Color.lightblue
export var background_image : Texture = null
export var border_image : Texture = null
export var border_color := Color.white
export var font : DynamicFont = null

#### ACCESSORS ####

func is_class(value: String): return value == "StreamPanelLayout" or .is_class(value)
func get_class() -> String: return "StreamPanelLayout"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
