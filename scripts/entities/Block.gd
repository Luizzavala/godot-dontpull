extends Area2D
class_name Block

## Gestiona el comportamiento de los bloques empujables en el grid.

const SLIDE_SPEED := GameConstants.TILE_SIZE / 0.2

var current_state: GameEnums.BlockState = GameEnums.BlockState.STATIC
var target_position: Vector2


func _ready() -> void:
    """Configura la posición objetivo inicial y registra el bloque."""
    target_position = global_position
    add_to_group("blocks")


func _physics_process(delta: float) -> void:
    """Actualiza el estado del bloque cada frame de física."""
    match current_state:
        GameEnums.BlockState.SLIDING:
            _process_sliding(delta)
        GameEnums.BlockState.DESTROYED:
            queue_free()


func request_slide(direction: Vector2i) -> bool:
    """Inicia el deslizamiento del bloque si la casilla destino está libre."""
    if current_state != GameEnums.BlockState.STATIC:
        return false
    var destination := target_position + Vector2(direction) * GameConstants.TILE_SIZE
    if GameHelpers.find_node_at_position("blocks", destination):
        return false
    target_position = destination
    current_state = GameEnums.BlockState.SLIDING
    return true


func _process_sliding(delta: float) -> void:
    """Mueve el bloque hacia la casilla destino y revisa colisiones básicas."""
    global_position = global_position.move_toward(target_position, SLIDE_SPEED * delta)
    if global_position.is_equal_approx(target_position):
        global_position = target_position
        var enemy := GameHelpers.find_node_at_position("enemies", target_position)
        if enemy and enemy is Enemy:
            (enemy as Enemy).set_dead_state()
            GameManager.add_score(10)
        current_state = GameEnums.BlockState.STATIC


func destroy_block() -> void:
    """Marca el bloque como destruido para que sea eliminado del nivel."""
    current_state = GameEnums.BlockState.DESTROYED
