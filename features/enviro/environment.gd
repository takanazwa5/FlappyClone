class_name Enviro extends Node2D


signal point_acquired

const FLOOR_CHUNK : PackedScene = preload("res://scenes/floor_chunk/floor_chunk.tscn")
const PIPE : PackedScene = preload("res://scenes/pipe/pipe.tscn")

var floor_chunks : Array[Node] = []
var pipes : Array[Node] = []

var speed : int = 100
var can_start_spawning_pipes : bool = false


func _ready() -> void:
	for child : Node in %FloorChunks.get_children():
		child.get_node("VOSN").screen_exited.connect(on_floor_chunk_screen_exited)
		child.get_node("Area").body_entered.connect(on_area_body_entered)
		floor_chunks.append(child)

	for child : Node in %Pipes.get_children():
		child.get_node("VOSN").screen_exited.connect(on_pipe_screen_exited)
		child.get_node("PipeTop/Area").body_entered.connect(on_area_body_entered)
		child.get_node("PipeBottom/Area").body_entered.connect(on_area_body_entered)
		child.get_node("PointArea").body_entered.connect(on_point_area_body_entered)
		pipes.append(child)


func _physics_process(delta: float) -> void:
	for chunk : Sprite2D in floor_chunks:
		chunk.position.x -= speed * delta

	if not can_start_spawning_pipes:
		return

	for pipe : Node2D in pipes:
		pipe.position.x -= speed * delta


func on_floor_chunk_screen_exited() -> void:
	var new_chunk : Sprite2D = FLOOR_CHUNK.instantiate()
	new_chunk.position = floor_chunks[-1].position + Vector2(336, 0)
	new_chunk.get_node("VOSN").screen_exited.connect(on_floor_chunk_screen_exited)
	new_chunk.get_node("Area").body_entered.connect(on_area_body_entered)
	floor_chunks.append(new_chunk)
	%FloorChunks.add_child(new_chunk)
	floor_chunks.pop_front().queue_free()


func on_pipe_screen_exited() -> void:
	pipes.pop_front().queue_free()


func on_area_body_entered(body: Node2D) -> void:
	if body is Bird and not body.dead:
		speed = 0
		body.die()
		can_start_spawning_pipes = false


func on_point_area_body_entered(_body: Node2D) -> void:
	var new_pipe : Node2D = PIPE.instantiate()
	new_pipe.position = Vector2(pipes[-1].position.x + 200, randi_range(100, 300))
	new_pipe.get_node("VOSN").screen_exited.connect(on_pipe_screen_exited)
	new_pipe.get_node("PipeTop/Area").body_entered.connect(on_area_body_entered)
	new_pipe.get_node("PipeBottom/Area").body_entered.connect(on_area_body_entered)
	new_pipe.get_node("PointArea").body_entered.connect(on_point_area_body_entered)
	pipes.append(new_pipe)
	%Pipes.call_deferred("add_child", new_pipe)

	point_acquired.emit()
