extends Node2D

class_name Level

var Player = preload("res://components/Player.tscn")

func _ready() -> void:
    if $PlayerSpawn != null:
        var player = Player.instance()
        player.position = $PlayerSpawn.position
        add_child(player)
