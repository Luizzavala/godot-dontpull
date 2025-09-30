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


func _ready() -> void:
    """Inicializa la posición objetivo y registra al jugador en el GameManager."""
    target_position = global_position
    GameManager.register_player(self)
    add_to_group("player")


func _physics_process(delta: float) -> void:
    """Actualiza la máquina de estados del jugador."""
    match current_state:
        Enums.PlayerState.IDLE:
            _process_idle_state()
        Enums.PlayerState.MOVE:
            _process_move_state(delta)
        Enums.PlayerState.PUSH:
            _process_push_state(delta)
        Enums.PlayerState.DEAD:
            pass


func _process_idle_state() -> void:
    """Evalúa la entrada del usuario cuando el jugador está en reposo."""
    var input_direction := _read_input()
    if input_direction == Vector2i.ZERO:
        return
    _attempt_movement(input_direction)


func _process_move_state(delta: float) -> void:
    """Interpola el desplazamiento hacia la casilla objetivo."""
    global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)
    if global_position.is_equal_approx(target_position):
        global_position = target_position
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
        return
    if GameHelpers.find_node_at_position("enemies", destination):
        _set_dead_state()
        return
    current_state = Enums.PlayerState.MOVE
    target_position = destination


func _read_input() -> Vector2i:
    """Obtiene la dirección de entrada discreta desde WASD o flechas."""
    var direction := Vector2i.ZERO
    direction.y -= int(Input.is_action_pressed("move_up"))
    direction.y += int(Input.is_action_pressed("move_down"))
    direction.x -= int(Input.is_action_pressed("move_left"))
    direction.x += int(Input.is_action_pressed("move_right"))
    if direction.x != 0 and direction.y != 0:
        direction.y = 0
    return direction


func _set_dead_state() -> void:
    """Activa el estado de muerte y notifica al GameManager."""
    current_state = Enums.PlayerState.DEAD
    GameManager.on_player_defeated()
