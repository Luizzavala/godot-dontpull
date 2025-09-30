extends Control
class_name MainMenu

## Presenta el menú principal y gestiona la transición al primer nivel.
const LEVEL_SCENE_PATH := "res://scenes/core/Level.tscn"

@onready var start_button: Button = %StartButton

func _ready() -> void:
    """Conecta señales del botón de inicio."""
    start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
    """Carga la escena del nivel principal."""
    get_tree().change_scene_to_file(LEVEL_SCENE_PATH)
