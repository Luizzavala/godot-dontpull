## TestHighScoreJson valida la carga robusta de datos desde disco.
extends Node

const HighScoreService = preload("res://scripts/core/HighScoreService.gd")

func run_tests() -> Array:
    HighScoreService.clear_scores()
    var results := [
        _test_loads_scores_from_valid_json(),
        _test_returns_empty_on_invalid_json(),
        _test_ignores_entries_without_score(),
    ]
    HighScoreService.clear_scores()
    return results


func _test_loads_scores_from_valid_json() -> Dictionary:
    var payload := [
        {"initials": "abc", "score": 1200, "timestamp": 10},
        {"initials": "XYZ", "score": 900, "timestamp": 20},
    ]
    _write_payload(payload)
    _reset_cache()
    var scores := HighScoreService.get_high_scores()
    var passed := scores.size() == 2
        and scores[0].get("initials") == "ABC"
        and scores[0].get("score") == 1200
        and scores[1].get("initials") == "XYZ"
        and scores[1].get("score") == 900
    return {
        "name": "HighScoreService carga puntuaciones válidas desde JSON",
        "passed": passed,
    }


func _test_returns_empty_on_invalid_json() -> Dictionary:
    _write_raw("{ invalid json }")
    _reset_cache()
    var scores := HighScoreService.get_high_scores()
    return {
        "name": "HighScoreService ignora archivos JSON inválidos",
        "passed": scores.is_empty(),
    }


func _test_ignores_entries_without_score() -> Dictionary:
    var payload := [
        {"initials": "AAA", "score": 500},
        {"initials": "BBB"},
        "not a dictionary",
    ]
    _write_payload(payload)
    _reset_cache()
    var scores := HighScoreService.get_high_scores()
    var passed := scores.size() == 1 and scores[0].get("initials") == "AAA"
    return {
        "name": "HighScoreService descarta entradas sin score",
        "passed": passed,
    }


func _write_payload(payload: Array) -> void:
    var file := FileAccess.open(HighScoreService.SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(payload))
    file.close()


func _write_raw(content: String) -> void:
    var file := FileAccess.open(HighScoreService.SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(content)
    file.close()


func _reset_cache() -> void:
    HighScoreService._scores.clear()
    HighScoreService._is_loaded = false
