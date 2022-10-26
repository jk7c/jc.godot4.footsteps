@tool
class_name FootstepsSurface extends FootstepsSurfaceAudio

@export_group("Surface List")
@export var surface_textures: Array[Texture]

func exist(texture: Texture) -> bool:
	if texture == null:
		return false
	
	if surface_textures.has(texture):
		return true
	
	return false
