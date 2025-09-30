extends Node2D
class_name Block

##
# Block representa los bloques empujables que pueden deslizarse y destruir
# enemigos al impactar.
##

const TILE_SIZE := 64
const SLIDE_SPEED := 10.0

enum State { STATIC, SLIDING, DESTROYED }

var state: State = State.STATIC
var game_manager: GameManager
var grid_position: Vector2i = Vector2i.ZERO
var slide_direction: Vector2i = Vector2i.ZERO
var target_cell: Vector2i = Vector2i.ZERO
var target_position: Vector2 = Vector2.ZERO

##
# Configura el bloque con referencias del nivel y posición inicial.
##
func configure(manager: GameManager, start_cell: Vector2i) -> void:
    game_manager = manager
    grid_position = start_cell
    target_cell = start_cell
    if game_manager:
        target_position = game_manager.grid_to_world(start_cell)
        global_position = target_position
    else:
        target_position = global_position

##
# Inicia el deslizamiento del bloque si está en estado estático.
#
# @param direction Dirección a empujar.
# @return `true` si el bloque comienza a deslizarse.
##
func begin_slide(direction: Vector2i) -> bool:
    if state != State.STATIC:
        return false
    if not game_manager:
        return false
    var next_cell := grid_position + direction
    if not game_manager.can_block_occupy(self, next_cell):
        return false
    slide_direction = direction
    state = State.SLIDING
    target_cell = next_cell
    target_position = game_manager.grid_to_world(target_cell)
    return true

func _physics_process(delta: float) -> void:
    match state:
        State.SLIDING:
            _process_slide(delta)
        State.DESTROYED:
            pass
        State.STATIC:
            pass

func _process_slide(delta: float) -> void:
    var distance := global_position.distance_to(target_position)
    if distance <= 1.0:
        _on_slide_step_reached()
        return
    var step := SLIDE_SPEED * TILE_SIZE * delta
    global_position = global_position.move_toward(target_position, step)

func _on_slide_step_reached() -> void:
    global_position = target_position
    grid_position = target_cell
    if game_manager:
        game_manager.notify_block_cell(self, grid_position)
    var next_cell := grid_position + slide_direction
    if game_manager and game_manager.can_block_occupy(self, next_cell):
        target_cell = next_cell
        target_position = game_manager.grid_to_world(target_cell)
    else:
        state = State.STATIC
        slide_direction = Vector2i.ZERO

##
# Marca el bloque como destruido y libera su celda en el grid.
##
func destroy_block() -> void:
    state = State.DESTROYED
    if game_manager:
        game_manager.notify_block_destroyed(self)
    queue_free()
