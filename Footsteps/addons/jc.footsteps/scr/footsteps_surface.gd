@tool
class_name FootstepsSurface extends FootstepsSurfaceAudio

@export_group("Surface List")
@export var surfaces: Array[Texture]

func exist(texture: Texture) -> bool:
	if texture == null:
		return false
	
	if surfaces.has(texture):
		return true
	
	return false
