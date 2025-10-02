## AudioManager centraliza la reproducción de música y efectos de sonido.
extends Node
class_name AudioManagerService

const EVENT_BGM := StringName("bgm")
const EVENT_BLOCK_LAUNCH := StringName("block_launch")
const EVENT_BLOCK_DESTROY := StringName("block_destroy")
const EVENT_ENEMY_CRUSH := StringName("enemy_crush")
const EVENT_POWER_UP := StringName("power_up")
const EVENT_GAME_OVER := StringName("game_over")

var _players: Dictionary[StringName, AudioStreamPlayer] = {}

func _ready() -> void:
    """Crea los nodos de audio necesarios para los distintos eventos."""
    _initialize_players()

func play_bgm() -> void:
    """Inicia la reproducción del BGM si hay un stream disponible."""
    _ensure_players_ready()
    var player: AudioStreamPlayer = _players.get(EVENT_BGM, null)
    if player == null:
        return
    if player.playing:
        return
    player.play()

func stop_bgm() -> void:
    """Detiene la reproducción del BGM."""
    _ensure_players_ready()
    var player: AudioStreamPlayer = _players.get(EVENT_BGM, null)
    if player == null:
        return
    if player.playing:
        player.stop()

func play_block_launch() -> void:
    """Reproduce el efecto asociado al lanzamiento de bloque."""
    _ensure_players_ready()
    _restart_player(EVENT_BLOCK_LAUNCH)

func play_block_destroy() -> void:
    """Reproduce el efecto asociado a la destrucción de bloques."""
    _ensure_players_ready()
    _restart_player(EVENT_BLOCK_DESTROY)

func play_enemy_crush() -> void:
    """Reproduce el efecto al aplastar un enemigo."""
    _ensure_players_ready()
    _restart_player(EVENT_ENEMY_CRUSH)

func play_power_up() -> void:
    """Reproduce el efecto de recoger un power-up."""
    _ensure_players_ready()
    _restart_player(EVENT_POWER_UP)

func play_game_over() -> void:
    """Reproduce el efecto de Game Over."""
    _ensure_players_ready()
    _restart_player(EVENT_GAME_OVER)

func set_player_override(event_name: StringName, player: AudioStreamPlayer) -> void:
    """Permite sustituir un reproductor para pruebas o configuraciones especiales."""
    _ensure_players_ready()
    if not _players.has(event_name):
        return
    var current: AudioStreamPlayer = _players[event_name]
    if is_instance_valid(current):
        current.queue_free()
    var target_name := current.name if current else StringName(String(event_name) + "_player")
    player.name = target_name
    add_child(player)
    _players[event_name] = player

func get_player(event_name: StringName) -> AudioStreamPlayer:
    """Devuelve el reproductor asociado a un evento."""
    _ensure_players_ready()
    return _players.get(event_name, null)

func _restart_player(event_name: StringName) -> void:
    var player: AudioStreamPlayer = _players.get(event_name, null)
    if player == null:
        return
    if player.playing:
        player.stop()
    player.play()

func _ensure_player(node_name: String) -> AudioStreamPlayer:
    var player: AudioStreamPlayer = AudioStreamPlayer.new()
    player.name = node_name
    add_child(player)
    return player

func _initialize_players() -> void:
    if not _players.is_empty():
        return
    _players = {
        EVENT_BGM: _ensure_player("BGMPlayer"),
        EVENT_BLOCK_LAUNCH: _ensure_player("BlockLaunchPlayer"),
        EVENT_BLOCK_DESTROY: _ensure_player("BlockDestroyPlayer"),
        EVENT_ENEMY_CRUSH: _ensure_player("EnemyCrushPlayer"),
        EVENT_POWER_UP: _ensure_player("PowerUpPlayer"),
        EVENT_GAME_OVER: _ensure_player("GameOverPlayer"),
    }
    for player: AudioStreamPlayer in _players.values():
        player.stream = null
        player.autoplay = false
        player.bus = "Master"
        player.process_mode = Node.PROCESS_MODE_ALWAYS

    var bgm_player: AudioStreamPlayer = _players.get(EVENT_BGM, null)
    if bgm_player and not bgm_player.finished.is_connected(_on_bgm_finished):
        bgm_player.finished.connect(_on_bgm_finished)

func _ensure_players_ready() -> void:
    if _players.is_empty():
        _initialize_players()

func _on_bgm_finished() -> void:
    var player: AudioStreamPlayer = _players.get(EVENT_BGM, null)
    if player == null:
        return
    player.play()
