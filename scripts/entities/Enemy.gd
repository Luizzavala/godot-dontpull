## Enemy implementa una IA simple con patrullaje y persecución básica del jugador.
extends CharacterBody2D
class_name Enemy

const Enums = preload("res://scripts/utils/enums.gd")
const Consts = preload("res://scripts/utils/constants.gd")
const ENEMY_STEP_TIME := Consts.ENEMY_STEP_TIME
const MOVE_SPEED := Consts.TILE_SIZE / ENEMY_STEP_TIME

var current_state: Enums.EnemyState = Enums.EnemyState.PATROL
var target_position: Vector2 = Vector2.ZERO
var patrol_cooldown: float = 0.0

func _ready() -> void:
    """Inicializa valores y registra al enemigo en el GameManager."""
    target_position = global_position
    GameManager.register_enemy(self)
    add_to_group("enemies")

func _physics_process(delta: float) -> void:
    """Actualiza la lógica de IA en cada frame de física."""
    if current_state != Enums.EnemyState.DEAD:
        if _should_chase():
            current_state = Enums.EnemyState.CHASE
        elif current_state == Enums.EnemyState.CHASE:
            current_state = Enums.EnemyState.PATROL
    match current_state:
        Enums.EnemyState.PATROL:
            _process_patrol_state(delta)
        Enums.EnemyState.CHASE:
            _process_chase_state(delta)
        Enums.EnemyState.DEAD:
            pass

func _process_patrol_state(delta: float) -> void:
    """Mueve al enemigo aleatoriamente cuando no detecta al jugador."""
    patrol_cooldown -= delta
    if patrol_cooldown <= 0.0 and global_position.is_equal_approx(target_position):
        var directions: Array = Consts.CARDINAL_DIRECTIONS.duplicate()
        directions.shuffle()
        for direction: Vector2i in directions:
            if _attempt_step(direction):
                break
        patrol_cooldown = ENEMY_STEP_TIME
    _advance(delta)

func _process_chase_state(delta: float) -> void:
    """Persigue al jugador si está en rango manhattan <= 2."""
    var player: Player = GameManager.get_player()
    if player == null:
        return
    if global_position.is_equal_approx(target_position):
        var delta_pos: Vector2i = GameHelpers.world_to_grid(player.global_position) - GameHelpers.world_to_grid(global_position)
        var x_dir: int = int(sign(delta_pos.x))
        var y_dir: int = int(sign(delta_pos.y))
        var primary_direction: Vector2i = Vector2i(x_dir, 0) if abs(delta_pos.x) > abs(delta_pos.y) else Vector2i(0, y_dir)
        if primary_direction == Vector2i.ZERO:
            primary_direction = Vector2i(x_dir, y_dir)
        if not _attempt_step(primary_direction):
            var alternatives: Array = Consts.CARDINAL_DIRECTIONS.duplicate()
            alternatives.shuffle()
            for direction: Vector2i in alternatives:
                if _attempt_step(direction):
                    break
    _advance(delta)

func _advance(delta: float) -> void:
    """Interpola el desplazamiento hacia la posición objetivo actual."""
    global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)
    if global_position.is_equal_approx(target_position):
        global_position = target_position

func _attempt_step(direction: Vector2i) -> bool:
    """Calcula un destino potencial y valida colisiones básicas."""
    var destination: Vector2 = target_position + Vector2(direction) * Consts.TILE_SIZE
    var destination_grid: Vector2i = GameHelpers.world_to_grid(destination)
    if not GameHelpers.is_within_bounds(destination_grid):
        return false
    if GameHelpers.find_node_at_position("blocks", destination):
        return false
    target_position = destination
    return true

func _should_chase() -> bool:
    """Determina si el jugador está lo suficientemente cerca para iniciar la persecución."""
    var player: Player = GameManager.get_player()
    if player == null:
        return false
    var distance: Vector2i = GameHelpers.world_to_grid(player.global_position) - GameHelpers.world_to_grid(global_position)
    return abs(distance.x) + abs(distance.y) <= Consts.ENEMY_CHASE_RANGE

func set_dead_state() -> void:
    """Activa el estado de muerte y notifica al GameManager."""
    current_state = Enums.EnemyState.DEAD
    GameManager.on_enemy_defeated(self)
    queue_free()
