extends Control

var levels
var level_names

var Overworld = preload("res://levels/Overworld.tscn")

onready var CurrentLevel = $ViewportContainer/CurrentLevel
onready var DebugPanel = $Overlay/DebugPanel
onready var LevelButtons = $Overlay/DebugPanel/LevelButtons

func _ready() -> void:
    levels = []
    level_names = []
    var dir = Directory.new()
    if dir.open("res://levels") == OK:
        dir.list_dir_begin(true, true)
        var filename = "ugh"
        while filename != "":
            filename = dir.get_next()
            if filename.ends_with(".tscn"):
                var level = load("res://levels/%s" % filename)
                levels.append(level)
                level_names.append(filename.replace(".tscn", ""))

    for i in range(len(levels)):
        var button = LevelLoaderButton.new()
        button.level_name = level_names[i]
        button.text = "Load %s" % level_names[i]
        button.connect("pressed", self, "_on_LevelLoaderButton_pressed", [i])
        LevelButtons.add_child(button)

    switch_level(Overworld, "")

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_quit"):
        get_tree().quit()

func _on_LevelLoaderButton_pressed(level_index: int) -> void:
    switch_level(levels[level_index], "")

func switch_level(level: PackedScene, direction: String) -> void:
    get_tree().paused = true
    var exit_animation = null
    var enter_animation = null
    if direction == "up":
        exit_animation = "ScrollDown"
        enter_animation = "ScrollUp"
    elif direction == "down":
        exit_animation = "ScrollUp"
        enter_animation = "ScrollDown"

    if exit_animation:
        $LevelSwitchAnimator.play(exit_animation)
        yield($LevelSwitchAnimator, "animation_finished")

    var node = level.instance()
    print("Setting level to %s" % node.name)
    if CurrentLevel.get_child_count() > 0:
        assert(CurrentLevel.get_child_count() == 1)
        CurrentLevel.get_child(0).free()
    CurrentLevel.add_child(node)

    for vent in get_tree().get_nodes_in_group("vents"):
        vent.destination
        vent.connect("entered", self, "switch_level", [vent.destination, "down"])

    if enter_animation:
        $LevelSwitchAnimator.play_backwards(enter_animation)
        yield($LevelSwitchAnimator, "animation_finished")
    else:
        $View.rect_position.y = 0
    get_tree().paused = false
