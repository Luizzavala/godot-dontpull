extends CharacterBody2D
class_name Player

##
# Player implementa una FSM simple para gestionar movimiento, empuje de
# bloques y estado de muerte dentro de un grid discreto.
##

const TILE_SIZE := 64
const MOVE_SPEED := 6.0

enum State { IDLE, MOVE, PUSH, DEAD }

var state: State = State.IDLE
var game_manager: GameManager
var grid_position: Vector2i = Vector2i.ZERO
var target_cell: Vector2i = Vector2i.ZERO
var target_position: Vector2 = Vector2.ZERO
var move_direction: Vector2i = Vector2i.ZERO

const INPUT_DIRECTIONS := {
    "move_up": Vector2i.UP,
    "move_down": Vector2i.DOWN,
    "move_left": Vector2i.LEFT,
    "move_right": Vector2i.RIGHT,
}

##
# Configura el jugador con referencias del nivel.
#
# @param manager Referencia al GameManager.
# @param start_cell Celda inicial del jugador.
##
func configure(manager: GameManager, start_cell: Vector2i) -> void:
    game_manager = manager
    grid_position = start_cell
    target_cell = start_cell
    move_direction = Vector2i.ZERO
    if game_manager:
        target_position = game_manager.grid_to_world(start_cell)
        global_position = target_position
    else:
        target_position = global_position

##
# Reinicia FSM a estado inactivo.
##
func reset_state() -> void:
    state = State.IDLE
    move_direction = Vector2i.ZERO
    target_cell = grid_position
    target_position = global_position

func _physics_process(delta: float) -> void:
    match state:
        State.IDLE:
            _handle_input()
        State.MOVE, State.PUSH:
            _process_movement(delta)
        State.DEAD:
            velocity = Vector2.ZERO

func _handle_input() -> void:
    if not game_manager:
        return
    for action in INPUT_DIRECTIONS.keys():
        if Input.is_action_just_pressed(action):
            var direction: Vector2i = INPUT_DIRECTIONS[action]
            _attempt_move(direction)
            break

func _attempt_move(direction: Vector2i) -> void:
    if direction == Vector2i.ZERO:
        return
    var result: GameManager.MoveType = game_manager.try_player_move(direction)
    match result:
        GameManager.MoveType.WALK:
            _start_move(direction, State.MOVE)
        GameManager.MoveType.PUSH:
            _start_move(direction, State.PUSH)
        GameManager.MoveType.NONE:
            pass

func _start_move(direction: Vector2i, new_state: State) -> void:
    grid_position += direction
    target_cell = grid_position
    move_direction = direction
    state = new_state
    target_position = game_manager.grid_to_world(target_cell)

func _process_movement(delta: float) -> void:
    var distance := global_position.distance_to(target_position)
    if distance <= 1.0:
        global_position = target_position
        state = State.IDLE
        move_direction = Vector2i.ZERO
        return
    var step := MOVE_SPEED * TILE_SIZE * delta
    var new_position := global_position.move_toward(target_position, step)
    global_position = new_position

##
# Cambia el estado del jugador a muerte e informa al GameManager.
##
func on_defeated() -> void:
    if state == State.DEAD:
        return
    state = State.DEAD
    velocity = Vector2.ZERO
    if game_manager:
        game_manager.on_player_defeated()
