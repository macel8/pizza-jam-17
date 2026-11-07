extends Node3D

signal chunk_changed(chunk_pos: Vector2i)

@export var player: Node3D
@export var load_distance := 5
@export_custom(PROPERTY_HINT_LINK, "suffix:m") var chunk_size = Vector2(32, 32)
@export_dir var chunk_files: String

@onready var resource_preloader: ResourcePreloader = $ResourcePreloader
@onready var chunks: Node3D = $Chunks

var chunk_dict: Dictionary[Vector2i, Node3D]
var current_chunk: Vector2i

func get_chunk_pos() -> Vector2i:
	# Might change later depending on chunk origin in actuall chunks
	#var chunk_x = floori((player.position.x + (chunk_size.x / 2)) / chunk_size.x)
	#var chunk_y = floori((player.position.z + (chunk_size.y / 2)) / chunk_size.y)
	var chunk_x = roundi(player.position.x / chunk_size.x)
	var chunk_y = roundi(player.position.z / chunk_size.y)
	return Vector2i(chunk_x, chunk_y)

func _ready() -> void:
	current_chunk = get_chunk_pos()
	chunk_changed.emit(current_chunk)

func _physics_process(_delta: float) -> void:
	var chunk_pos = get_chunk_pos()
	
	if chunk_pos != current_chunk:
		chunk_changed.emit(chunk_pos)
		current_chunk = chunk_pos

func _on_chunk_changed(chunk_pos: Vector2i) -> void:
	for y in range(-load_distance, load_distance + 1):
		for x in range(-load_distance, load_distance + 1):
			var pos := chunk_pos + Vector2i(x, y)
			
			# Unload border chunks
			if abs(y) == load_distance or abs(x) == load_distance:
				var chunk: Node3D = chunk_dict.get(pos)
				if chunk:
					chunk.queue_free()
					chunk_dict.erase(pos)
					print("Unloaded chunk [%s] at: %s" % [chunk, pos])
				continue
			
			# Load new chunks
			if pos not in chunk_dict:
				var chunk := load_random_chunk(pos)
				chunk_dict[pos] = chunk
				

func load_random_chunk(chunk_pos: Vector2i) -> Node3D:
	var resouces := resource_preloader.get_resource_list()
	var resource_name := resouces[randi() % resouces.size()]
	var resource := resource_preloader.get_resource(resource_name)
	
	var instance: Node3D = resource.instantiate()
	instance.position.x = chunk_pos.x * chunk_size.x
	instance.position.z = chunk_pos.y * chunk_size.y
	instance.rotation.y = (PI/2) * (randi() % 4)
	chunks.add_child(instance)
	
	print("Loaded chunk [%s] at: %s" % [resource_name, chunk_pos])
	return instance
