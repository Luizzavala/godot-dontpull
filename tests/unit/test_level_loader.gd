## TestLevelLoader valida la carga de archivos JSON de nivel.
extends Node

const LevelLoader = preload("res://scripts/utils/level_loader.gd")

func run_tests() -> Array:
    """Ejecuta los casos asociados al LevelLoader."""
    return [
        _test_load_default_level(),
        _test_missing_level_returns_empty(),
        _test_relative_path_resolution(),
    ]


func _test_load_default_level() -> Dictionary:
    var data := LevelLoader.load_level(LevelLoader.get_default_level_path())
    var player_data := data.get("player", {})
    var start := player_data.get("start", [])
    return {
        "name": "LevelLoader carga el nivel por defecto",
        "passed": data.get("name", "") == "Orchard-01" and start.size() == 2,
    }


func _test_missing_level_returns_empty() -> Dictionary:
    var data := LevelLoader.load_level("res://levels/unknown_level.json")
    return {
        "name": "LevelLoader devuelve diccionario vacío si falta el archivo",
        "passed": data.is_empty(),
    }


func _test_relative_path_resolution() -> Dictionary:
    var data := LevelLoader.load_level("level_01.json")
    return {
        "name": "LevelLoader resuelve rutas relativas al directorio de niveles",
        "passed": data.get("name", "") == "Orchard-01",
    }
