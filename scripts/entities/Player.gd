extends CharacterBody2D
class_name Player
"""Controla al jugador en grid y procesa entrada multiplataforma."""
const Enums = preload("res://scripts/utils/enums.gd")
const Consts = preload("res://scripts/utils/constants.gd")
const DEADZONE := 0.2
const MOVE_SPEED := Consts.TILE_SIZE / Consts.PLAYER_MOVE_STEP_TIME

var state: Enums.PlayerState = Enums.PlayerState.IDLE
var target_position: Vector2 = Vector2.ZERO
var move_direction: Vector2 = Vector2.ZERO
func _ready() -> void:
    """Configura el jugador al entrar en la escena."""
    target_position = global_position
    GameManager.register_player(self)
    add_to_group("player")

func _physics_process(_delta: float) -> void:
    """Actualiza la máquina de estados del jugador en cada frame de física."""
    match state:
        Enums.PlayerState.IDLE:
            _handle_idle_state()
        Enums.PlayerState.MOVE:
            _advance_move()
        Enums.PlayerState.PUSH:
            _handle_push_state()
        Enums.PlayerState.DEAD:
            velocity = Vector2.ZERO

func _handle_idle_state() -> void:
    var input_vector: Vector2 = _get_input_vector()
    if input_vector == Vector2.ZERO:
        velocity = Vector2.ZERO
        return
    _try_start_move(_vector_to_cardinal(input_vector))
func _handle_push_state() -> void:
    _advance_move(true) # Placeholder hasta implementar animación y feedback específicos.

func _get_input_vector() -> Vector2:
    var direction: Vector2 = _strength_vector("move_left", "move_right", "move_up", "move_down")
    direction += _strength_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if direction.length() < DEADZONE:
        return Vector2.ZERO
    return direction.normalized()

func _strength_vector(left: StringName, right: StringName, up: StringName, down: StringName) -> Vector2:
    var horizontal: float = Input.get_action_strength(right) - Input.get_action_strength(left)
    var vertical: float = Input.get_action_strength(down) - Input.get_action_strength(up)
    return Vector2(horizontal, vertical)

func _vector_to_cardinal(input_vector: Vector2) -> Vector2i:
    if input_vector == Vector2.ZERO:
        return Vector2i.ZERO
    return Vector2i(
        int(sign(input_vector.x)) if abs(input_vector.x) >= abs(input_vector.y) else 0,
        int(sign(input_vector.y)) if abs(input_vector.y) > abs(input_vector.x) else 0
    )

func _try_start_move(direction: Vector2i) -> void:
    if direction == Vector2i.ZERO:
        return
    var destination: Vector2 = target_position + Vector2(direction) * Consts.TILE_SIZE
    var destination_grid: Vector2i = GameHelpers.world_to_grid(destination)
    if not GameHelpers.is_within_bounds(destination_grid):
        return
    var block_node: Node = GameHelpers.find_node_at_position("blocks", destination)
    if block_node and block_node is Block:
        if (block_node as Block).request_slide(direction):
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
    return (global_position - target_position).dot(move_direction) >= 0.0

func _set_dead_state() -> void:
    """Activa el estado de muerte y notifica al GameManager."""
    state = Enums.PlayerState.DEAD
    GameManager.on_player_defeated()
