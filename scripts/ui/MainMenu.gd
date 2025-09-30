extends Control
class_name MainMenu

##
# MainMenu ofrece un botón para cargar la escena principal del nivel.
##

@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)

##
# Cambia a la escena de nivel principal.
##
func _on_start_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/Level.tscn")
