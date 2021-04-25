extends Control

const LEVEL_SPACING = 840
var levels
var level_ids
var vent_up_levelids
var vent_down_levelids

var Player = preload("res://components/Player.tscn")

onready var DebugPanel = $Overlay/DebugPanel
onready var LevelButtons = $Overlay/DebugPanel/LevelButtons

var currentlevelid = null
var player
var just_vented = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_quit"):
        get_tree().quit()

func _ready() -> void:
    levels = $Levels.get_children()
    level_ids = {}
    for i in range(len(levels)):
        var level = levels[i]
        level_ids[level] = i

        level.position.y = LEVEL_SPACING * i

        var button = Button.new()
        button.text = "Switch to %s" % i
        button.connect("pressed", self, "switch_level", [i, ""])
        LevelButtons.add_child(button)

    vent_down_levelids = {}
    for vent in get_tree().get_nodes_in_group("vent_down"):
        var name = vent.name.replace("vent_", "")
        var levelid = level_ids[vent.get_parent()]
        vent_down_levelids[name] = levelid

    vent_up_levelids = {}
    for vent in get_tree().get_nodes_in_group("vent_up"):
        var name = vent.name.replace("vent_", "")
        var levelid = level_ids[vent.get_parent()]
        vent_up_levelids[name] = levelid

    for vent in get_tree().get_nodes_in_group("vent_down"):
        var name = vent.name.replace("vent_", "")
        var levelid = vent_up_levelids[name]
        vent.connect("entered", self, "switch_level", [levelid, name])

    for vent in get_tree().get_nodes_in_group("vent_up"):
        var name = vent.name.replace("vent_", "")
        var levelid = vent_down_levelids[name]
        vent.connect("entered", self, "switch_level", [levelid, name])

    switch_level(0, "")

func switch_level(levelid: int, vent_name: String) -> void:
    if just_vented:
        just_vented = false
        return
    if vent_name:
        just_vented = true
    print("Switching to level %s" % levelid)
    var nextlevel = levels[levelid]

    # start the camera moving
    $Camera.position.y = levelid * LEVEL_SPACING

    # animate the player shrinking?

    # move the player
    if player != null:
        player.queue_free()

    yield(get_tree().create_timer(0.2), "timeout")
    player = Player.instance()
    var destvent
    if vent_name == "":
        for node in nextlevel.get_children():
            if node.name == "spawn":
                destvent = node
                break
    else:
        for node in nextlevel.get_children():
            if node.name == "vent_%s" % vent_name:
                destvent = node
                break
    player.position = destvent.position
    nextlevel.add_child_below_node(destvent, player)

    currentlevelid = levelid
