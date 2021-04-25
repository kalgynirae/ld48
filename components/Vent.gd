extends Node2D

class_name Vent
export(PackedScene) var destination
signal entered


func _on_Area2D_body_entered(body: Node) -> void:
    emit_signal("entered")
