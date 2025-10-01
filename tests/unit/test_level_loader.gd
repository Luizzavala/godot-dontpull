## TestLevelLoader valida la carga de archivos JSON de nivel.
extends Node

const LevelLoader = preload("res://scripts/utils/level_loader.gd")

func run_tests() -> Array:
    """Ejecuta los casos asociados al LevelLoader."""
    return [
        _test_load_default_level(),
        _test_level_contains_labyrinth_layout(),
        _test_level_reports_powerups(),
        _test_missing_level_returns_empty(),
        _test_relative_path_resolution(),
    ]


func _test_load_default_level() -> Dictionary:
    var data := LevelLoader.load_level(LevelLoader.get_default_level_path())
    var player_data := data.get("player", {})
    var start := player_data.get("start", [])
    var grid_size := data.get("grid_size", {})
    return {
        "name": "LevelLoader carga el nivel por defecto",
        "passed": data.get("name", "") == "Orchard-01"
            and start.size() == 2
            and int(grid_size.get("width", 0)) >= 13
            and int(grid_size.get("height", 0)) >= 11,
    }


func _test_level_contains_labyrinth_layout() -> Dictionary:
    var data := LevelLoader.load_level("res://levels/level_01.json")
    var blocks: Array = data.get("blocks", [])
    return {
        "name": "LevelLoader obtiene el layout del laberinto",
        "passed": blocks.size() >= 40,
    }


func _test_level_reports_powerups() -> Dictionary:
    var data := LevelLoader.load_level("res://levels/level_02.json")
    var power_ups: Array = data.get("power_ups", [])
    var has_named_entries := true
    for entry in power_ups:
        if not (entry is Dictionary and entry.has("type") and entry.has("position")):
            has_named_entries = false
            break
    return {
        "name": "LevelLoader conserva los power-ups con tipo y posición",
        "passed": power_ups.size() >= 3 and has_named_entries,
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
