extends Node
class_name GameManager

## Administra el estado global del juego, incluyendo score, vidas y flujo de niveles.

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_started(level_name: String)
signal game_over()

var current_state: GameEnums.GameState = GameEnums.GameState.MENU
var score := 0
var lives := GameConstants.PLAYER_START_LIVES
var current_level: Node
var player: Player
var enemies: Array[Enemy] = []

func _ready() -> void:
    """Configura listeners globales al iniciar el autoload."""
    if get_parent() != get_tree().get_root():
        if not Engine.is_editor_hint():
            queue_free()
            return
    get_tree().connect("current_scene_changed", Callable(self, "_on_current_scene_changed"))
    emit_signal("score_changed", score)
    emit_signal("lives_changed", lives)

func register_player(new_player: Player) -> void:
    """Guarda una referencia al jugador activo."""
    player = new_player

func register_enemy(enemy: Enemy) -> void:
    """Añade enemigos activos para referencia rápida."""
    if enemy not in enemies:
        enemies.append(enemy)

func register_hud() -> void:
    """Reemite el estado inicial cuando el HUD se monta."""
    emit_signal("score_changed", score)
    emit_signal("lives_changed", lives)

func start_level(level_node: Node) -> void:
    """Inicializa la información del nivel actual."""
    current_level = level_node
    current_state = GameEnums.GameState.PLAYING
    emit_signal("level_started", level_node.name)
    emit_signal("score_changed", score)
    emit_signal("lives_changed", lives)

func notify_player_step() -> void:
    """Incrementa el score por cada paso válido del jugador."""
    add_score(GameConstants.SCORE_PER_STEP)

func add_score(amount: int) -> void:
    """Aumenta el score global y notifica a la UI."""
    score += amount
    emit_signal("score_changed", score)

func on_enemy_defeated(enemy: Enemy) -> void:
    """Gestiona la derrota de un enemigo y actualiza score."""
    enemies.erase(enemy)
    add_score(25)

func on_player_defeated() -> void:
    """Resta una vida y evalúa fin de partida."""
    lives -= 1
    emit_signal("lives_changed", lives)
    if lives <= 0:
        current_state = GameEnums.GameState.GAME_OVER
        emit_signal("game_over")
        return_to_menu()
    else:
        restart_level()

func restart_level() -> void:
    """Recarga la escena actual para reiniciar el nivel."""
    if current_level:
        get_tree().reload_current_scene()

func return_to_menu() -> void:
    """Carga el menú principal y restablece datos básicos."""
    current_state = GameEnums.GameState.MENU
    lives = GameConstants.PLAYER_START_LIVES
    score = 0
    emit_signal("score_changed", score)
    get_tree().change_scene_to_file(GameConstants.MAIN_MENU_SCENE_PATH)

func get_player() -> Player:
    """Devuelve el jugador activo si existe."""
    return player

func _on_current_scene_changed(new_scene: Node) -> void:
    """Detecta cambios de escena para iniciar niveles automáticamente."""
    if new_scene and new_scene.scene_file_path == GameConstants.LEVEL_SCENE_PATH:
        start_level(new_scene)
    else:
        current_level = null
