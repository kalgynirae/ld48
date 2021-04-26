# vim: expandtab
extends Control

const LEVEL_SPACING = 840
var levels
var level_ids
var vent_up_levelids
var vent_down_levelids

var music_players

var Player = preload("res://components/Player.tscn")

onready var DebugPanel = $Overlay/DebugPanel
onready var LevelButtons = $Overlay/DebugPanel/LevelButtons

var currentlevelid = null
var player
var just_vented = false

var goal_count
var displayed_goal_count
var obtained_goals
var seen_levels

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_quit"):
        get_tree().quit()

func show_debug_panel() -> void:
    DebugPanel.modulate = Color(1, 1, 1, 0.5)
    $DebugPanelTimer.start()

func hide_debug_panel() -> void:
    DebugPanel.modulate = Color(1, 1, 1, 0.05)

func _ready() -> void:
    setup_levels()
    setup_vents()
    setup_goals()
    setup_switch()
    setup_music()
    switch_level(0, "")

func setup_levels() -> void:
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

        var deeper = $Deeper/deeper.duplicate()
        deeper.position.x = 640
        deeper.position.y = LEVEL_SPACING * (i + 1) - 60
        $Deeper.add_child(deeper)

        var shallower = $Shallower/shallower.duplicate()
        shallower.position.x = 640
        shallower.position.y = LEVEL_SPACING * (i + 1) - 60
        $Shallower.add_child(shallower)

func setup_vents() -> void:
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
        if vent.noentry:
            vent.connect("entered", self, "clear_vented_state")
        else:
            var name = vent.name.replace("vent_", "")
            var levelid = vent_up_levelids[name]
            vent.connect("entered", self, "switch_level", [levelid, name])

    for vent in get_tree().get_nodes_in_group("vent_up"):
        if vent.noentry:
            vent.connect("entered", self, "clear_vented_state")
        else:
            var name = vent.name.replace("vent_", "")
            var levelid = vent_down_levelids[name]
            vent.connect("entered", self, "switch_level", [levelid, name])

func setup_music():
    music_players = []
    for music in $Music.get_children():
        music_players.append(music)
        music.play()

func switch_level(levelid: int, vent_name: String) -> void:
    print("switch_level(%s, %s)" % [levelid, vent_name])
    if just_vented:
        just_vented = false
        return
    if vent_name:
        just_vented = true
    print("Switching to level %s" % levelid)
    var nextlevel = levels[levelid]

    # show deeper/shallower labels
    if currentlevelid != null:
        $Shallower.visible = currentlevelid > levelid
        $Deeper.visible = currentlevelid < levelid

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

    # change music
    if currentlevelid != null:
        AudioServer.set_bus_mute(1 + currentlevelid, true)
    AudioServer.set_bus_mute(1 + levelid, false)

    currentlevelid = levelid

    if vent_name != "":
        yield(get_tree().create_timer(0.8), "timeout")
    update_goals()

func clear_vented_state() -> void:
    just_vented = false

func setup_goals() -> void:
    goal_count = 0
    displayed_goal_count = 0
    obtained_goals = 0
    seen_levels = []
    $GoalCountTimer.start()

func obtain_goal(goal: Node) -> void:
    obtained_goals += 1
    goal.queue_free()

func update_goals() -> void:
    if not seen_levels.has(currentlevelid):
        for goal in get_tree().get_nodes_in_group("goal"):
            if levels[currentlevelid].is_a_parent_of(goal):
                goal_count += 1
                goal.connect("entered", self, "obtain_goal", [goal])
        seen_levels.append(currentlevelid)

func update_goal_label() -> void:
    if displayed_goal_count < goal_count:
        displayed_goal_count += 1
    $Overlay/ScorePanel/Label.text = "%s/%s" % [obtained_goals, displayed_goal_count]


func setup_switch() -> void:
    for switch in get_tree().get_nodes_in_group("switch"):
        switch.connect("flipped", self, "handle_switch_flip")

func handle_switch_flip() -> void:
    print("flip!")
    for vent in get_tree().get_nodes_in_group("vent_down"):
        vent.disconnect("entered", self, "clear_vented_state")
        var name = vent.name.replace("vent_", "")
        var levelid = vent_up_levelids[name]
        vent.connect("entered", self, "switch_level", [levelid, name])
    for vent in get_tree().get_nodes_in_group("vent_up"):
        vent.disconnect("entered", self, "clear_vented_state")
        var name = vent.name.replace("vent_", "")
        var levelid = vent_down_levelids[name]
        vent.connect("entered", self, "switch_level", [levelid, name])
    for jet in get_tree().get_nodes_in_group("jet"):
        jet.queue_free()
