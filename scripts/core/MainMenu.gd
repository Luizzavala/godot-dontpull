## MainMenu presenta el menú principal y gestiona la transición al primer nivel.
extends Control
class_name MainMenu

@onready var start_button: Button = %StartButton
@onready var high_score_list: RichTextLabel = %HighScoreList

func _ready() -> void:
    """Conecta señales del botón de inicio."""
    start_button.pressed.connect(_on_start_button_pressed)
    GameManager.high_score_changed.connect(_on_high_score_changed)
    _refresh_high_scores()


func _on_start_button_pressed() -> void:
    """Carga la escena del nivel principal."""
    GameManager.start_new_game()


func _on_high_score_changed(_value: int) -> void:
    _refresh_high_scores()


func _refresh_high_scores() -> void:
    var entries := GameManager.get_high_scores()
    var lines: Array[String] = []
    for index in entries.size():
        var entry := entries[index]
        var initials := String(entry.get("initials", "AAA"))
        var score := int(entry.get("score", 0))
        lines.append("%d. %s - %d" % [index + 1, initials, score])
    if lines.is_empty():
        lines.append("No hay récords todavía")
    high_score_list.text = "\n".join(lines)
