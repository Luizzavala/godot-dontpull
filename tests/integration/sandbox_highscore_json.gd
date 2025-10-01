## SandboxHighScoreJson verifica la lectura de archivos de récords desde JSON.
extends Node2D

const HighScoreService = preload("res://scripts/core/HighScoreService.gd")
const MainMenuScene: PackedScene = preload("res://scenes/core/MainMenu.tscn")

func _ready() -> void:
    """Genera un archivo de récords y muestra el menú con los resultados."""
    HighScoreService.clear_scores()
    _write_sample_file()
    _reset_cache()
    HighScoreService.get_high_scores()
    var menu := MainMenuScene.instantiate()
    add_child(menu)


func _write_sample_file() -> void:
    var payload := [
        {"initials": "AAA", "score": 2000, "timestamp": 1},
        {"initials": "bbb", "score": 1500, "timestamp": 2},
        {"initials": "CCC"},
        "invalid",
    ]
    var file := FileAccess.open(HighScoreService.SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(payload, "  "))
    file.close()


func _reset_cache() -> void:
    HighScoreService._scores.clear()
    HighScoreService._is_loaded = false
