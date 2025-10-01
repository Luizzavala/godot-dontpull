## SandboxHighScore carga la tabla de récords con datos de ejemplo.
extends Node2D

const HighScoreService = preload("res://scripts/core/HighScoreService.gd")
const MainMenuScene: PackedScene = preload("res://scenes/core/MainMenu.tscn")

func _ready() -> void:
    """Inicializa puntuaciones de ejemplo y muestra el menú."""
    HighScoreService.clear_scores()
    HighScoreService.submit_score("AAA", 1200)
    HighScoreService.submit_score("BBB", 900)
    HighScoreService.submit_score("CCC", 750)
    var menu := MainMenuScene.instantiate()
    add_child(menu)
