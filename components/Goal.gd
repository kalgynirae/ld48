extends Node2D

signal entered

func _ready() -> void:
    $AnimationPlayer.play("Rotate")

func _on_Area2D_body_entered(_body: Node) -> void:
    emit_signal("entered")
