extends CharacterBody2D
class_name Enemy

## Implementa una IA simple con patrullaje y persecución básica del jugador.

const MOVE_SPEED := GameConstants.TILE_SIZE / GameConstants.ENEMY_STEP_TIME

var current_state: GameEnums.EnemyState = GameEnums.EnemyState.PATROL
var target_position: Vector2
var patrol_cooldown := 0.0


func _ready() -> void:
    """Inicializa valores y registra al enemigo en el GameManager."""
    target_position = global_position
    GameManager.register_enemy(self)
    add_to_group("enemies")


func _physics_process(delta: float) -> void:
    """Actualiza la lógica de IA en cada frame de física."""
    if current_state != GameEnums.EnemyState.DEAD:
        if _should_chase():
            current_state = GameEnums.EnemyState.CHASE
        elif current_state == GameEnums.EnemyState.CHASE:
            current_state = GameEnums.EnemyState.PATROL
    match current_state:
        GameEnums.EnemyState.PATROL:
            _process_patrol_state(delta)
        GameEnums.EnemyState.CHASE:
            _process_chase_state(delta)
        GameEnums.EnemyState.DEAD:
            pass


func _process_patrol_state(delta: float) -> void:
    """Mueve al enemigo aleatoriamente cuando no detecta al jugador."""
    patrol_cooldown -= delta
    if patrol_cooldown <= 0.0 and global_position.is_equal_approx(target_position):
        var directions := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
        directions.shuffle()
        for direction in directions:
            if _attempt_step(direction):
                break
        patrol_cooldown = GameConstants.ENEMY_STEP_TIME
    _advance(delta)


func _process_chase_state(delta: float) -> void:
    """Persigue al jugador si está en rango manhattan <= 2."""
    var player := GameManager.get_player()
    if player == null:
        return
    if global_position.is_equal_approx(target_position):
        var delta_pos := GameHelpers.world_to_grid(player.global_position) - GameHelpers.world_to_grid(global_position)
        var primary_direction := Vector2i(sign(delta_pos.x), 0) if abs(delta_pos.x) > abs(delta_pos.y) else Vector2i(0, sign(delta_pos.y))
        if primary_direction == Vector2i.ZERO:
            primary_direction = Vector2i(sign(delta_pos.x), sign(delta_pos.y))
        if not _attempt_step(primary_direction):
            var alternatives := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
            alternatives.shuffle()
            for direction in alternatives:
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
    var destination := target_position + Vector2(direction) * GameConstants.TILE_SIZE
    if GameHelpers.find_node_at_position("blocks", destination):
        return false
    target_position = destination
    return true


func _should_chase() -> bool:
    """Determina si el jugador está lo suficientemente cerca para iniciar la persecución."""
    var player := GameManager.get_player()
    if player == null:
        return false
    var distance := GameHelpers.world_to_grid(player.global_position) - GameHelpers.world_to_grid(global_position)
    return abs(distance.x) + abs(distance.y) <= 2


func set_dead_state() -> void:
    """Activa el estado de muerte y notifica al GameManager."""
    current_state = GameEnums.EnemyState.DEAD
    GameManager.on_enemy_defeated(self)
    queue_free()
