## SandboxResolution permite alternar resoluciones para validar que no existan áreas invisibles.
extends Node2D

const LevelScene: PackedScene = preload("res://scenes/core/Level.tscn")

@export var resolutions: Array[Vector2i] = [
    Vector2i(640, 640),
    Vector2i(960, 720),
    Vector2i(1280, 720),
]

var _resolution_index := 0
var _level: Level
@onready var resolution_label: Label = %ResolutionLabel

func _ready() -> void:
    """Instancia el nivel base y fija la resolución inicial."""
    _level = LevelScene.instantiate()
    add_child(_level)
    _apply_resolution(resolutions[_resolution_index])
    _update_label()

func _unhandled_input(event: InputEvent) -> void:
    """Permite cambiar de resolución con las flechas laterales."""
    if event.is_action_pressed("ui_right"):
        _resolution_index = (_resolution_index + 1) % resolutions.size()
        _apply_resolution(resolutions[_resolution_index])
        _update_label()
    elif event.is_action_pressed("ui_left"):
        _resolution_index = (_resolution_index - 1 + resolutions.size()) % resolutions.size()
        _apply_resolution(resolutions[_resolution_index])
        _update_label()

func _apply_resolution(size: Vector2i) -> void:
    get_viewport().size = size

func _update_label() -> void:
    var active_size := resolutions[_resolution_index]
    resolution_label.text = "Resolución: %dx%d" % [active_size.x, active_size.y]
