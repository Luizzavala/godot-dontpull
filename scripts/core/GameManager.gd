## GameManager administra el estado global del juego y expone señales a las escenas.
extends Node

const Consts = preload("res://scripts/utils/constants.gd")

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_started(level_name: String)
signal game_over()

var _player: Player
var _score := 0
var _lives := Consts.START_LIVES
var _enemies: Array[Enemy] = []

func _ready() -> void:
    """Emite el estado inicial al arrancar el autoload."""
    get_tree().scene_changed.connect(_on_scene_changed)
    score_changed.emit(_score)
    lives_changed.emit(_lives)

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

func start_level() -> void:
    """Propaga el inicio del nivel actual al HUD."""
    var current_scene := get_tree().current_scene
    level_started.emit(current_scene.name if current_scene else "")

func register_enemy(enemy: Enemy) -> void:
    """Añade enemigos activos para referencia rápida."""
    if enemy not in _enemies:
        _enemies.append(enemy)

func on_enemy_defeated(enemy: Enemy) -> void:
    """Elimina la referencia del enemigo y suma score."""
    _enemies.erase(enemy)
    add_score(Consts.ENEMY_SCORE)

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
        start_level()
