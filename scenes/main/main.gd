class_name Main extends Node


const DIGIT_RECTS : Dictionary = {
	0 : Vector2(1, 24),
	1 : Vector2(27, 16),
	2 : Vector2(45, 24),
	3 : Vector2(71, 24),
	4 : Vector2(97, 24),
	5 : Vector2(123, 24),
	6 : Vector2(149, 24),
	7 : Vector2(175, 24),
	8 : Vector2(201, 24),
	9 : Vector2(227, 24),
}

var points : int = 0
var digits : Array[Sprite2D]

@onready var bird : Bird = %Bird
@onready var enviro : Enviro = %Environment
@onready var points_digit : Sprite2D = %PointsDigit
@onready var sprites_animations : AnimationPlayer = %SpritesAnimations
@onready var bird_animations : AnimationPlayer = %BirdAnimations
@onready var point_sfx : AudioStreamPlayer = %PointSFX


func _ready() -> void:
	bird.request_start.connect(on_start_requested)
	bird.request_restart.connect(on_restart_requested)
	bird.died.connect(on_bird_died)
	enviro.point_acquired.connect(on_point_acquired)

	digits.append(points_digit)


func on_start_requested() -> void:
	enviro.can_start_spawning_pipes = true
	bird.is_gravity_on = true
	sprites_animations.play("hide")
	bird_animations.stop()


func on_restart_requested() -> void:
	if not sprites_animations.is_playing():
		get_tree().reload_current_scene()


func on_bird_died() -> void:
	sprites_animations.play("game_over")


func on_point_acquired() -> void:
	points += 1
	point_sfx.play()

	if points == pow(10, digits.size()):
		add_digit()

	update_digits()


func add_digit() -> void:
	for digit : Node in digits:
		digit.position.x -= 12
	var new_digit : Sprite2D = digits[-1].duplicate()
	new_digit.position.x += 24
	digits[-1].add_sibling(new_digit)
	digits.append(new_digit)


func update_digits() -> void:
	for i in digits.size():
		var digit : int = str(points).split()[i].to_int()
		var x : int = DIGIT_RECTS.get(digit).x
		var w : int = DIGIT_RECTS.get(digit).y
		digits[i].region_rect = Rect2(x, 1, w, 36)
