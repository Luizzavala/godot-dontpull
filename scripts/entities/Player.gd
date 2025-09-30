## Controla al jugador en grid, administra su FSM y gestiona interacciones con el entorno.
extends CharacterBody2D
class_name Player

const Enums = preload("res://scripts/utils/enums.gd")
const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")
const DEADZONE := 0.2
const MOVE_SPEED := Consts.TILE_SIZE / Consts.PLAYER_MOVE_STEP_TIME

var state: Enums.PlayerState = Enums.PlayerState.IDLE
var target_position: Vector2 = Vector2.ZERO
var move_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
    """Inicializa la posición objetivo y registra al jugador."""
    target_position = global_position
    GameManager.register_player(self)
    add_to_group("player")

func _physics_process(_delta: float) -> void:
    """Actualiza la máquina de estados del jugador cada frame de física."""
    match state:
        Enums.PlayerState.IDLE:
            velocity = Vector2.ZERO
            _try_start_move(_vector_to_cardinal(_read_input()))
        Enums.PlayerState.MOVE:
            _advance_move()
        Enums.PlayerState.PUSH:
            _advance_move(true)
        Enums.PlayerState.DEAD:
            velocity = Vector2.ZERO

func _read_input() -> Vector2:
    var direction := _vector_from_actions("move_left", "move_right", "move_up", "move_down")
    direction += _vector_from_actions("ui_left", "ui_right", "ui_up", "ui_down")
    if direction.length() < DEADZONE:
        return Vector2.ZERO
    return direction.normalized()

func _vector_from_actions(left: StringName, right: StringName, up: StringName, down: StringName) -> Vector2:
    return Vector2(
        Input.get_action_strength(right) - Input.get_action_strength(left),
        Input.get_action_strength(down) - Input.get_action_strength(up)
    )

func _vector_to_cardinal(input_vector: Vector2) -> Vector2i:
    if input_vector == Vector2.ZERO:
        return Vector2i.ZERO
    return Vector2i(int(sign(input_vector.x)), 0) if abs(input_vector.x) > abs(input_vector.y) else Vector2i(0, int(sign(input_vector.y)))

func _try_start_move(direction: Vector2i) -> void:
    if direction == Vector2i.ZERO:
        return
    var destination := target_position + Vector2(direction) * Consts.TILE_SIZE
    var block := GameHelpers.find_node_at_position("blocks", destination)
    if block and block is Block:
        if (block as Block).request_slide(direction):
            state = Enums.PlayerState.PUSH
            _begin_move(destination, direction)
        return
    if GameHelpers.find_node_at_position("enemies", destination):
        _set_dead_state()
        return
    state = Enums.PlayerState.MOVE
    _begin_move(destination, direction)

func _begin_move(destination: Vector2, direction: Vector2i) -> void:
    target_position = destination
    move_direction = Vector2(direction)

func _advance_move(is_push: bool = false) -> void:
    if move_direction == Vector2.ZERO:
        state = Enums.PlayerState.IDLE
        velocity = Vector2.ZERO
        return
    velocity = move_direction * MOVE_SPEED
    move_and_slide()
    if _reached_target():
        global_position = target_position
        velocity = Vector2.ZERO
        move_direction = Vector2.ZERO
        state = Enums.PlayerState.IDLE
        if not is_push:
            GameManager.notify_player_step()

func _reached_target() -> bool:
    return (
        (move_direction.x > 0.0 and global_position.x >= target_position.x) or
        (move_direction.x < 0.0 and global_position.x <= target_position.x) or
        (move_direction.y > 0.0 and global_position.y >= target_position.y) or
        (move_direction.y < 0.0 and global_position.y <= target_position.y)
    )

func _set_dead_state() -> void:
    """Activa el estado de muerte y notifica al GameManager."""
    state = Enums.PlayerState.DEAD
    GameManager.on_player_defeated()
