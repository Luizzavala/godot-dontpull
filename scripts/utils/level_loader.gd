## LevelLoader ofrece utilidades para cargar descripciones de niveles desde JSON.
extends Object
class_name LevelLoader

const Consts = preload("res://scripts/utils/constants.gd")

static func get_default_level_path() -> String:
    """Devuelve la ruta completa del nivel por defecto."""
    return Consts.LEVELS_DIR + Consts.DEFAULT_LEVEL_FILE


static func load_level(path: String) -> Dictionary:
    """Carga un archivo JSON de nivel y devuelve su contenido como diccionario."""
    var resolved_path := _resolve_path(path)
    if resolved_path == "":
        return {}
    if not FileAccess.file_exists(resolved_path):
        push_warning("Nivel no encontrado: %s" % resolved_path)
        return {}
    var file := FileAccess.open(resolved_path, FileAccess.READ)
    if file == null:
        push_warning("No se pudo abrir el archivo de nivel: %s" % resolved_path)
        return {}
    var json := JSON.new()
    var parse_error := json.parse(file.get_as_text())
    if parse_error != OK:
        push_warning("Error al parsear nivel %s: %s" % [resolved_path, json.get_error_message()])
        return {}
    return json.data if json.data is Dictionary else {}


static func _resolve_path(path: String) -> String:
    if path == "":
        return ""
    if path.begins_with("res://"):
        return path
    return Consts.LEVELS_DIR + path
