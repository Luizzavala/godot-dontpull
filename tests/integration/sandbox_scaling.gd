## SandboxScaling permite validar visualmente el escalado y centrado del área jugable.
extends Node2D

const LevelScene: PackedScene = preload("res://scenes/core/Level.tscn")
const Consts = preload("res://scripts/utils/constants.gd")

@export var level_files: Array[String] = [
    "level_01.json",
    "level_02.json",
    "level_03.json",
]

@export var resolutions: Array[Vector2i] = [
    Consts.BASE_RESOLUTION,
    Vector2i(960, 720),
    Vector2i(1280, 960),
]

var _level_index := 0
var _resolution_index := 0
var _level: Level
var _last_info := ""

@onready var info_label: Label = %InfoLabel

func _ready() -> void:
    set_process(true)
    _load_current_level()
    _apply_resolution(resolutions[_resolution_index])
    _update_info_label()

func _process(_delta: float) -> void:
    _update_info_label()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_right"):
        _resolution_index = (_resolution_index + 1) % resolutions.size()
        _apply_resolution(resolutions[_resolution_index])
    elif event.is_action_pressed("ui_left"):
        _resolution_index = (_resolution_index - 1 + resolutions.size()) % resolutions.size()
        _apply_resolution(resolutions[_resolution_index])
    elif event.is_action_pressed("ui_down"):
        _level_index = (_level_index - 1 + level_files.size()) % level_files.size()
        _load_current_level()
    elif event.is_action_pressed("ui_up"):
        _level_index = (_level_index + 1) % level_files.size()
        _load_current_level()

func _load_current_level() -> void:
    if is_instance_valid(_level):
        _level.queue_free()
    _level = LevelScene.instantiate()
    _level.level_file = Consts.LEVELS_DIR + level_files[_level_index]
    add_child(_level)

func _apply_resolution(size: Vector2i) -> void:
    get_viewport().size = size

func _update_info_label() -> void:
    if not is_instance_valid(_level):
        return
    var viewport_size: Vector2 = _level.get_viewport_rect().size
    var camera: Camera2D = _level.get_node_or_null("%Camera2D")
    if camera == null:
        return
    var grid_size: Vector2i = _level.get_grid_size()
    var info := "Nivel: %s (%dx%d) | Resolución: %dx%d | Zoom: %.2f" % [
        _level.get_level_name(),
        grid_size.x,
        grid_size.y,
        int(viewport_size.x),
        int(viewport_size.y),
        camera.zoom.x,
    ]
    if info == _last_info:
        return
    _last_info = info
    info_label.text = info + "\nFlechas: Izq/Der resolución, Arriba/Abajo nivel"
