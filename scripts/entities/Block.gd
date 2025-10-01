## Block gestiona el comportamiento de los bloques empujables en el grid.
extends Area2D
class_name Block

const Enums = preload("res://scripts/utils/enums.gd")
const Consts = preload("res://scripts/utils/constants.gd")
const SLIDE_TIME := Consts.BLOCK_SLIDE_TIME
const SLIDE_SPEED := Consts.TILE_SIZE / SLIDE_TIME
const BLOCK_KILL_SCORE := Consts.BLOCK_KILL_SCORE

var current_state: Enums.BlockState = Enums.BlockState.STATIC
var target_position: Vector2
var _kill_registered: bool = false


func _ready() -> void:
    """Configura la posición objetivo inicial y registra el bloque."""
    target_position = global_position
    add_to_group("blocks")
    body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
    """Actualiza el estado del bloque cada frame de física."""
    match current_state:
        Enums.BlockState.SLIDING:
            _process_sliding(delta)
        Enums.BlockState.DESTROYED:
            queue_free()


func request_slide(direction: Vector2i) -> bool:
    """Inicia el deslizamiento del bloque si la casilla destino está libre."""
    if current_state != Enums.BlockState.STATIC:
        return false
    var destination: Vector2 = target_position + Vector2(direction) * Consts.TILE_SIZE
    if GameHelpers.find_node_at_position("blocks", destination):
        return false
    _kill_registered = false
    target_position = destination
    current_state = Enums.BlockState.SLIDING
    return true


func _process_sliding(delta: float) -> void:
    """Mueve el bloque hacia la casilla destino y revisa colisiones básicas."""
    global_position = global_position.move_toward(target_position, SLIDE_SPEED * delta)
    if global_position.is_equal_approx(target_position):
        global_position = target_position
        _finalize_slide()


func destroy_block() -> void:
    """Marca el bloque como destruido para que sea eliminado del nivel."""
    current_state = Enums.BlockState.DESTROYED


func _on_body_entered(body: Node) -> void:
    """Gestiona la colisión con enemigos durante el deslizamiento."""
    if current_state != Enums.BlockState.SLIDING:
        return
    if body is Enemy:
        _resolve_enemy_collision(body as Enemy)


func _resolve_enemy_collision(enemy: Enemy) -> void:
    """Elimina al enemigo aplastado y otorga la bonificación correspondiente."""
    if _kill_registered:
        return
    _kill_registered = true
    enemy.set_dead_state()
    GameManager.add_score(BLOCK_KILL_SCORE)
    target_position = GameHelpers.grid_to_world(GameHelpers.world_to_grid(enemy.global_position))
    global_position = target_position
    current_state = Enums.BlockState.STATIC


func _finalize_slide() -> void:
    """Completa el deslizamiento verificando si se aplastó a un enemigo."""
    if _kill_registered:
        _kill_registered = false
        return
    var enemy_node: Node = GameHelpers.find_node_at_position("enemies", target_position)
    if enemy_node and enemy_node is Enemy:
        _resolve_enemy_collision(enemy_node as Enemy)
        _kill_registered = false
        return
    current_state = Enums.BlockState.STATIC
