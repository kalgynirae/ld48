extends Node2D

signal flipped

var is_flipped

func _ready() -> void:
    is_flipped = false
    $switch_on.visible = true
    $switch_off.visible = false

func _on_Area2D_body_entered(_body: Node) -> void:
    if not is_flipped:
        emit_signal("flipped")
        is_flipped = true
        $switch_on.visible = false
        $switch_off.visible = true
