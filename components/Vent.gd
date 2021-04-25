extends Node2D

export(bool) var noentry
signal entered
signal exited

func _on_Area2D_body_entered(_body: Node) -> void:
    emit_signal("entered")

func _on_Area2D_body_exited(_body: Node) -> void:
    emit_signal("exited")
