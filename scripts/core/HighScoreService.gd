## HighScoreService gestiona la tabla de récords persistente del juego.
extends Object
class_name HighScoreService

const SAVE_PATH := "user://scores.json"
const MAX_ENTRIES := 10
const INITIALS_LENGTH := 3

static var _scores: Array[Dictionary] = []
static var _is_loaded := false


static func get_high_scores() -> Array[Dictionary]:
    """Devuelve una copia de las puntuaciones almacenadas de mayor a menor."""
    _ensure_loaded()
    return _scores.duplicate(true)


static func get_high_score_value() -> int:
    """Devuelve la puntuación más alta registrada."""
    _ensure_loaded()
    if _scores.is_empty():
        return 0
    return int(_scores[0].get("score", 0))


static func submit_score(initials: String, score: int) -> Array[Dictionary]:
    """Registra una nueva puntuación y devuelve la tabla actualizada."""
    _ensure_loaded()
    if score <= 0:
        return get_high_scores()
    var entry := _create_entry(initials, score)
    _scores.append(entry)
    _sort_scores()
    if _scores.size() > MAX_ENTRIES:
        _scores.resize(MAX_ENTRIES)
    _save_scores()
    return get_high_scores()


static func clear_scores(remove_file := true) -> void:
    """Elimina todas las puntuaciones registradas."""
    _scores.clear()
    _is_loaded = true
    if remove_file:
        _remove_save_file()
    else:
        _save_scores()


static func _ensure_loaded() -> void:
    if _is_loaded:
        return
    _load_scores_from_disk()
    _is_loaded = true


static func _create_entry(initials: String, score: int) -> Dictionary:
    return {
        "initials": _sanitize_initials(initials),
        "score": int(score),
        "timestamp": Time.get_unix_time_from_system(),
    }


static func _sanitize_initials(initials: String) -> String:
    var trimmed := initials.strip_edges().to_upper()
    if trimmed == "":
        trimmed = "AAA"
    if trimmed.length() > INITIALS_LENGTH:
        trimmed = trimmed.substr(0, INITIALS_LENGTH)
    while trimmed.length() < INITIALS_LENGTH:
        trimmed += "A"
    return trimmed


static func _sort_scores() -> void:
    _scores.sort_custom(func(a: Dictionary, b: Dictionary):
        var score_a := int(a.get("score", 0))
        var score_b := int(b.get("score", 0))
        if score_a == score_b:
            return int(a.get("timestamp", 0)) < int(b.get("timestamp", 0))
        return score_a > score_b
    )


static func _load_scores_from_disk() -> void:
    _scores.clear()
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var content := file.get_as_text()
    var data := JSON.parse_string(content)
    if data == null:
        return
    if data is Array:
        for element in data:
            if element is Dictionary and element.has("score"):
                var entry := {
                    "initials": _sanitize_initials(String(element.get("initials", "AAA"))),
                    "score": int(element.get("score", 0)),
                    "timestamp": int(element.get("timestamp", 0)),
                }
                _scores.append(entry)
    _sort_scores()


static func _save_scores() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(_scores, "  "))


static func _remove_save_file() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var absolute_path := ProjectSettings.globalize_path(SAVE_PATH)
    DirAccess.remove_absolute(absolute_path)
