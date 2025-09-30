extends CanvasLayer
class_name HUD

## Gestiona la visualización del score, vidas y nombre del nivel mediante señales.

signal score_updated(new_score: int)
signal lives_updated(new_lives: int)

@onready var score_label: Label = %ScoreLabel
@onready var lives_label: Label = %LivesLabel
@onready var level_label: Label = %LevelLabel

func _ready() -> void:
    """Conecta el HUD al GameManager y muestra valores iniciales."""
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.lives_changed.connect(_on_lives_changed)
    GameManager.level_started.connect(_on_level_started)
    GameManager.register_hud(self)


func _on_score_changed(value: int) -> void:
    """Actualiza el label de score cuando cambia el valor."""
    score_label.text = str(value)
    emit_signal("score_updated", value)


func _on_lives_changed(value: int) -> void:
    """Actualiza el label de vidas cuando cambia el valor."""
    lives_label.text = str(value)
    emit_signal("lives_updated", value)


func _on_level_started(level_name: String) -> void:
    """Muestra el nombre del nivel activo."""
    level_label.text = level_name
