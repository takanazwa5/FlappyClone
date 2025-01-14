class_name Bird extends CharacterBody2D


signal request_start
signal request_restart
signal died

const JUMP_VELOCITY : float = 300
const GRAVITY : int = 1000

var dead : bool = false
var is_gravity_on : bool = false
var can_request_start : bool = true

@onready var sprite : AnimatedSprite2D = %AnimatedSprite2D
@onready var wing_sfx : AudioStreamPlayer = %WingSFX
@onready var die_sfx : AudioStreamPlayer = %DieSFX


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tap") and position.y > 0:

		if not dead:
			velocity.y = -JUMP_VELOCITY

			if can_request_start:
				request_start.emit()
				can_request_start = false

			wing_sfx.play()

		else:
			request_restart.emit()

func _physics_process(delta: float) -> void:
	if is_gravity_on:
		velocity.y += GRAVITY * delta
	move_and_slide()


func _process(_delta: float) -> void:
	sprite.rotation_degrees = remap(velocity.y, -200.0, 400, -20.0, 20.0)


func die() -> void:
	dead = true
	sprite.stop()
	die_sfx.play()
	died.emit()
