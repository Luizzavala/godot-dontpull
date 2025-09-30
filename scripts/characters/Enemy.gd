extends CharacterBody2D
class_name Enemy

##
# Enemy modela una FSM básica con patrulla y persecución del jugador
# utilizando desplazamiento discreto en grid.
##

const TILE_SIZE := 64
const MOVE_SPEED := 5.0

enum State { PATROL, CHASE, DEAD }

var state: State = State.PATROL
var game_manager: GameManager
var grid_position: Vector2i = Vector2i.ZERO
var target_cell: Vector2i = Vector2i.ZERO
var target_position: Vector2 = Vector2.ZERO
var move_direction: Vector2i = Vector2i.RIGHT
var is_travelling: bool = false

##
# Configura el enemigo con referencias del nivel.
##
func configure(manager: GameManager, start_cell: Vector2i) -> void:
    game_manager = manager
    grid_position = start_cell
    target_cell = start_cell
    move_direction = Vector2i.RIGHT
    if game_manager:
        target_position = game_manager.grid_to_world(start_cell)
        global_position = target_position
    else:
        target_position = global_position

func _physics_process(delta: float) -> void:
    if state == State.DEAD:
        return
    if not is_travelling:
        match state:
            State.PATROL:
                _choose_patrol_target()
            State.CHASE:
                _choose_chase_target()
    if is_travelling:
        _process_travel(delta)
    if state != State.DEAD:
        _evaluate_chase_state()

func _choose_patrol_target() -> void:
    if not game_manager:
        return
    if not _try_move(move_direction):
        move_direction = -move_direction
        _try_move(move_direction)

func _choose_chase_target() -> void:
    if not game_manager:
        return
    var player_cell := game_manager.get_player_cell()
    var delta := player_cell - grid_position
    var desired := Vector2i.ZERO
    if abs(delta.x) > abs(delta.y):
        desired.x = sign(delta.x)
    elif abs(delta.y) > 0:
        desired.y = sign(delta.y)
    if desired == Vector2i.ZERO:
        state = State.PATROL
        return
    if not _try_move(desired):
        state = State.PATROL

func _try_move(direction: Vector2i) -> bool:
    if direction == Vector2i.ZERO:
        return false
    if not game_manager.try_enemy_move(self, direction):
        return false
    grid_position += direction
    target_cell = grid_position
    target_position = game_manager.grid_to_world(target_cell)
    move_direction = direction
    is_travelling = true
    return true

func _process_travel(delta: float) -> void:
    var distance := global_position.distance_to(target_position)
    if distance <= 1.0:
        global_position = target_position
        is_travelling = false
        return
    var step := MOVE_SPEED * TILE_SIZE * delta
    global_position = global_position.move_toward(target_position, step)

func _evaluate_chase_state() -> void:
    if not game_manager or state == State.DEAD:
        return
    var player_cell := game_manager.get_player_cell()
    if player_cell.x == grid_position.x or player_cell.y == grid_position.y:
        state = State.CHASE
    else:
        state = State.PATROL if state != State.PATROL else state

##
# Marca al enemigo como derrotado para evitar más actualizaciones.
##
func on_defeated() -> void:
    state = State.DEAD
    is_travelling = false
    velocity = Vector2.ZERO
