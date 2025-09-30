## Player controla el movimiento en grid del jugador y su interacción con bloques y enemigos.
extends CharacterBody2D
class_name Player

const Enums = preload("res://scripts/utils/enums.gd")
const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")
const MOVE_STEP_TIME := Consts.PLAYER_MOVE_STEP_TIME
const MOVE_SPEED := Consts.TILE_SIZE / MOVE_STEP_TIME

var current_state: Enums.PlayerState = Enums.PlayerState.IDLE
var target_position: Vector2
var move_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
    """Inicializa la posición objetivo y registra al jugador en el GameManager."""
    target_position = global_position
    GameManager.register_player(self)
    add_to_group("player")


func _physics_process(delta: float) -> void:
    """Actualiza la máquina de estados del jugador."""
    var input_vector := _get_input_vector()
    match current_state:
        Enums.PlayerState.IDLE:
            velocity = Vector2.ZERO
            if input_vector != Vector2.ZERO:
                _process_idle_state(input_vector)
        Enums.PlayerState.MOVE:
            _process_move_state(delta)
        Enums.PlayerState.PUSH:
            _process_push_state(delta)
        Enums.PlayerState.DEAD:
            velocity = Vector2.ZERO


func _process_idle_state(input_vector: Vector2) -> void:
    """Evalúa la entrada del usuario cuando el jugador está en reposo."""
    var input_direction := _vector_to_grid_direction(input_vector)
    if input_direction == Vector2i.ZERO:
        return
    _attempt_movement(input_direction)


func _process_move_state(delta: float) -> void:
    """Interpola el desplazamiento hacia la casilla objetivo."""
    if move_direction == Vector2.ZERO:
        velocity = Vector2.ZERO
        current_state = Enums.PlayerState.IDLE
        return
    velocity = move_direction * MOVE_SPEED
    move_and_slide()
    if _has_reached_target(delta):
        global_position = target_position
        velocity = Vector2.ZERO
        move_direction = Vector2.ZERO
        current_state = Enums.PlayerState.IDLE
        GameManager.notify_player_step()


func _process_push_state(delta: float) -> void:
    """Sincroniza el desplazamiento del jugador al empujar un bloque."""
    _process_move_state(delta)


func _attempt_movement(direction: Vector2i) -> void:
    """Gestiona el intento de movimiento o empuje según el contenido de la casilla objetivo."""
    var destination := target_position + Vector2(direction) * Consts.TILE_SIZE
    var blocking_node := GameHelpers.find_node_at_position("blocks", destination)
    if blocking_node and blocking_node is Block:
        if (blocking_node as Block).request_slide(direction):
            current_state = Enums.PlayerState.PUSH
            target_position = destination
            move_direction = Vector2(direction)
        return
    if GameHelpers.find_node_at_position("enemies", destination):
        _set_dead_state()
        return
    current_state = Enums.PlayerState.MOVE
    target_position = destination
    move_direction = Vector2(direction)


func _get_input_vector() -> Vector2:
    """Combina la entrada de teclado, d-pad y stick analógico."""
    var direction := Vector2.ZERO
    if Input.is_action_pressed("move_right"):
        direction.x += 1.0
    if Input.is_action_pressed("move_left"):
        direction.x -= 1.0
    if Input.is_action_pressed("move_down"):
        direction.y += 1.0
    if Input.is_action_pressed("move_up"):
        direction.y -= 1.0

    var analog_vector := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    )
    if analog_vector.length() > 0.2:
        direction += analog_vector

    if direction.length() == 0.0:
        return Vector2.ZERO
    return direction.normalized()


func _vector_to_grid_direction(input_vector: Vector2) -> Vector2i:
    """Convierte el vector de entrada en una dirección cardinal válida."""
    if input_vector == Vector2.ZERO:
        return Vector2i.ZERO
    var axis_vector := Vector2.ZERO
    if abs(input_vector.x) > abs(input_vector.y):
        axis_vector.x = sign(input_vector.x)
    elif abs(input_vector.y) > 0.0:
        axis_vector.y = sign(input_vector.y)
    return Vector2i(axis_vector)


func _has_reached_target(delta: float) -> bool:
    """Determina si el jugador llegó a la casilla objetivo considerando la velocidad."""
    var projected_step := MOVE_SPEED * delta
    var offset := target_position - global_position
    if move_direction.x > 0.0 and global_position.x >= target_position.x:
        return true
    if move_direction.x < 0.0 and global_position.x <= target_position.x:
        return true
    if move_direction.y > 0.0 and global_position.y >= target_position.y:
        return true
    if move_direction.y < 0.0 and global_position.y <= target_position.y:
        return true
    return offset.length() <= projected_step


func _set_dead_state() -> void:
    """Activa el estado de muerte y notifica al GameManager."""
    current_state = Enums.PlayerState.DEAD
    GameManager.on_player_defeated()
