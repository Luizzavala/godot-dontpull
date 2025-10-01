## GameManager administra el estado global del juego y expone señales a las escenas.
extends Node

const Consts = preload("res://scripts/utils/constants.gd")
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_started(level_name: String)
signal level_cleared(level_name: String)
signal level_transition_queued(next_level_file: String)
signal game_over()
var _player: Player
var _score := 0
var _lives := Consts.START_LIVES
var _enemies: Array[Enemy] = []
var _current_level_name: String = ""
var _current_level_file: String = ""
var _level_sequence: Array = Consts.LEVEL_SEQUENCE.duplicate()
var _current_level_index := 0
var _queued_level_file: String = Consts.DEFAULT_LEVEL_FILE
var _is_transitioning := false
func _ready() -> void:
    """Emite el estado inicial al arrancar el autoload."""
    get_tree().scene_changed.connect(_on_scene_changed)
    score_changed.emit(_score)
    lives_changed.emit(_lives)
    _queued_level_file = _get_default_level_file()

func start_new_game() -> void:
    """Reinicia puntuación, vidas y carga el primer nivel de la secuencia."""
    _score = 0
    _lives = Consts.START_LIVES
    _current_level_name = ""
    _current_level_file = ""
    _is_transitioning = false
    _enemies.clear()
    score_changed.emit(_score)
    lives_changed.emit(_lives)
    _queued_level_file = _get_default_level_file()
    var tree := get_tree()
    if tree:
        tree.change_scene_to_file(Consts.LEVEL_SCENE_PATH)

func register_player(player: Player) -> void:
    """Guarda la referencia del jugador activo."""
    _player = player

func register_hud(_hud: HUD) -> void:
    """Asocia el HUD activo y le envía el estado global."""
    score_changed.emit(_score)
    lives_changed.emit(_lives)

func add_score(value: int) -> void:
    """Incrementa el score global y notifica el cambio."""
    _score += value
    score_changed.emit(_score)

func set_lives(value: int) -> void:
    """Actualiza las vidas del jugador y dispara la señal correspondiente."""
    _lives = value
    lives_changed.emit(_lives)
    if _lives <= 0:
        game_over.emit()

func start_level(level_name: String = "", level_file: String = "") -> void:
    """Propaga el inicio del nivel actual al HUD."""
    var normalized_file := _normalize_level_file(level_file)
    if normalized_file != "":
        _current_level_file = normalized_file
        _queued_level_file = normalized_file
    elif _current_level_file == "":
        _current_level_file = _normalize_level_file(_queued_level_file)
    _is_transitioning = false
    _update_current_level_index()
    var resolved_name := level_name.strip_edges()
    if resolved_name == "":
        return
    if resolved_name == _current_level_name:
        level_started.emit(resolved_name)
        return
    _current_level_name = resolved_name
    level_started.emit(_current_level_name)

func register_enemy(enemy: Enemy) -> void:
    """Añade enemigos activos para referencia rápida."""
    if enemy not in _enemies:
        _enemies.append(enemy)

func unregister_enemy(enemy: Enemy) -> void:
    """Elimina un enemigo del registro sin otorgar puntuación."""
    _enemies.erase(enemy)

func on_enemy_defeated(enemy: Enemy) -> void:
    """Elimina la referencia del enemigo y suma score."""
    _enemies.erase(enemy)
    add_score(Consts.ENEMY_SCORE)
    if _enemies.is_empty():
        _handle_level_cleared()

func on_player_defeated() -> void:
    """Reduce las vidas del jugador y gestiona el reinicio o fin de partida."""
    set_lives(_lives - 1)
    if _lives > 0:
        restart_level()
    else:
        return_to_menu()

func restart_level() -> void:
    """Recarga el nivel actual si existe."""
    if get_tree().current_scene and get_tree().current_scene.scene_file_path == Consts.LEVEL_SCENE_PATH:
        get_tree().reload_current_scene()

func return_to_menu() -> void:
    """Regresa al menú principal y restablece score y vidas."""
    _score = 0
    _lives = Consts.START_LIVES
    _current_level_name = ""
    _current_level_file = ""
    _queued_level_file = _get_default_level_file()
    _is_transitioning = false
    _enemies.clear()
    score_changed.emit(_score)
    lives_changed.emit(_lives)
    get_tree().change_scene_to_file(Consts.MAIN_MENU_SCENE_PATH)

func get_player() -> Player:
    """Devuelve el jugador registrado."""
    return _player

func notify_player_step() -> void:
    """Suma score por cada paso válido del jugador."""
    add_score(Consts.STEP_SCORE)

func _on_scene_changed(new_scene: Node) -> void:
    """Detecta cambios de escena para iniciar niveles automáticamente."""
    if new_scene and new_scene.scene_file_path == Consts.LEVEL_SCENE_PATH:
        var level_name := ""
        var level_file := ""
        if new_scene.has_method("get_level_name"):
            level_name = String(new_scene.call("get_level_name"))
        if new_scene.has_method("get_level_file"):
            level_file = String(new_scene.call("get_level_file"))
        start_level(level_name, level_file)

func get_queued_level_file() -> String:
    """Devuelve el archivo configurado para cargarse en el siguiente nivel."""
    return _queued_level_file

func _handle_level_cleared() -> void:
    """Cola la transición al siguiente nivel cuando no quedan enemigos."""
    if _is_transitioning:
        return
    level_cleared.emit(_current_level_name)
    var next_level_file := _get_next_level_file()
    if next_level_file == "":
        _is_transitioning = false
        return
    _queued_level_file = next_level_file
    level_transition_queued.emit(_queued_level_file)
    _is_transitioning = true
    var tree := get_tree()
    if tree == null:
        return
    await tree.create_timer(Consts.LEVEL_TRANSITION_DELAY).timeout
    if _queued_level_file != next_level_file:
        return
    tree.change_scene_to_file(Consts.LEVEL_SCENE_PATH)

func _get_next_level_file() -> String:
    """Obtiene el siguiente archivo de nivel según la secuencia configurada."""
    if _level_sequence.is_empty():
        return _current_level_file
    var current_index := _current_level_index
    if current_index < 0 or current_index >= _level_sequence.size():
        current_index = 0
    var next_index := (current_index + 1) % _level_sequence.size()
    return String(_level_sequence[next_index])

func _get_default_level_file() -> String:
    """Devuelve el primer archivo de la secuencia o el nivel por defecto."""
    if _level_sequence.is_empty():
        return Consts.DEFAULT_LEVEL_FILE
    return String(_level_sequence[0])

func _normalize_level_file(path: String) -> String:
    """Normaliza la ruta del nivel para trabajar solo con el nombre del archivo."""
    if path == "":
        return ""
    var levels_dir := Consts.LEVELS_DIR
    if path.begins_with(levels_dir):
        return path.substr(levels_dir.length())
    if path.begins_with("res://") and path.find(levels_dir) != -1:
        var start_index := path.find(levels_dir) + levels_dir.length()
        return path.substr(start_index)
    return path

func _update_current_level_index() -> void:
    """Sincroniza el índice del nivel actual según la secuencia declarada."""
    if _level_sequence.is_empty():
        _current_level_file = _normalize_level_file(_current_level_file)
        _current_level_index = 0
        return
    var index := _level_sequence.find(_current_level_file)
    _current_level_index = index if index != -1 else 0
