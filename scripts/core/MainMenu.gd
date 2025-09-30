## MainMenu presenta el menú principal y gestiona la transición al primer nivel.
extends Control
class_name MainMenu

const Consts = preload("res://scripts/utils/constants.gd")

@onready var start_button: Button = %StartButton

func _ready() -> void:
    """Conecta señales del botón de inicio."""
    start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
    """Carga la escena del nivel principal."""
    get_tree().change_scene_to_file(Consts.LEVEL_SCENE_PATH)
