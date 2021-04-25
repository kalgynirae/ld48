extends KinematicBody2D

const SPEED = 20
const ACCELERATION = 200
const BOOST_ACCELERATION = 100
const FRICTION = 50
var velocity = Vector2()

func _physics_process(delta: float) -> void:
    velocity += (get_direction() * ACCELERATION * delta).clamped(SPEED)
    var boost = get_boost_direction()
    velocity += boost * BOOST_ACCELERATION
    if boost != Vector2.ZERO:
        $Boost.emitting = true
    velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta + (velocity.length_squared() / 5000))
    velocity = move_and_slide(velocity)

func get_boost_direction() -> Vector2:
    var x = int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left"))
    var y = int(Input.is_action_just_pressed("ui_down")) - int(Input.is_action_just_pressed("ui_up"))
    return Vector2(x, y).normalized()

func get_direction() -> Vector2:
    var x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
    var y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
    return Vector2(x, y).normalized()
