## Block gestiona el comportamiento de los bloques empujables en el grid.
extends Area2D
class_name Block

const Enums = preload("res://scripts/utils/enums.gd")
const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")
const SLIDE_TIME := Consts.BLOCK_SLIDE_TIME
const SLIDE_SPEED := Consts.TILE_SIZE / SLIDE_TIME
const BLOCK_KILL_SCORE := Consts.BLOCK_KILL_SCORE

var current_state: Enums.BlockState = Enums.BlockState.STATIC
var target_position: Vector2
var _slide_origin: Vector2 = Vector2.ZERO
var _launch_direction: Vector2i = Vector2i.ZERO
var _kill_registered: bool = false
var _feedback_tween: Tween


func _ready() -> void:
    """Configura la posición objetivo inicial y registra el bloque."""
    target_position = global_position
    _slide_origin = target_position
    add_to_group("blocks")
    body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
    """Actualiza el estado del bloque cada frame de física."""
    match current_state:
        Enums.BlockState.LAUNCHED:
            _process_sliding(delta)
        Enums.BlockState.DESTROYED:
            queue_free()


func request_slide(direction: Vector2i) -> bool:
    """Inicia el lanzamiento del bloque recorriendo la línea hasta encontrar un obstáculo."""
    if current_state != Enums.BlockState.STATIC:
        return false
    if direction == Vector2i.ZERO:
        return false
    var current_grid: Vector2i = GameHelpers.world_to_grid(target_position)
    var final_destination: Vector2 = target_position
    var step_grid: Vector2i = current_grid + direction
    while GameHelpers.is_within_bounds(step_grid):
        var step_world: Vector2 = GameHelpers.grid_to_world(step_grid)
        if GameHelpers.find_node_at_position("blocks", step_world):
            break
        var enemy_node: Node = GameHelpers.find_node_at_position("enemies", step_world)
        final_destination = step_world
        if enemy_node:
            break
        step_grid += direction
    if final_destination.is_equal_approx(target_position):
        return false
    _kill_registered = false
    _slide_origin = target_position
    target_position = final_destination
    _launch_direction = direction
    current_state = Enums.BlockState.LAUNCHED
    _play_launch_feedback()
    var audio_manager := _get_audio_manager()
    if audio_manager:
        audio_manager.play_block_launch()
    return true


func _process_sliding(delta: float) -> void:
    """Mueve el bloque hacia la casilla destino y revisa colisiones básicas."""
    global_position = global_position.move_toward(target_position, SLIDE_SPEED * delta)
    if global_position.is_equal_approx(target_position):
        global_position = target_position
        _finalize_slide()


func destroy_block() -> void:
    """Marca el bloque como destruido para que sea eliminado del nivel."""
    if current_state == Enums.BlockState.DESTROYED:
        return
    current_state = Enums.BlockState.DESTROYED
    _play_destroy_feedback()
    var audio_manager := _get_audio_manager()
    if audio_manager:
        audio_manager.play_block_destroy()
    queue_free()


func _on_body_entered(body: Node) -> void:
    """Gestiona la colisión con enemigos durante el deslizamiento."""
    if current_state != Enums.BlockState.LAUNCHED:
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
    _slide_origin = target_position
    _launch_direction = Vector2i.ZERO
    scale = Vector2.ONE
    modulate.a = 1.0


func occupies_world_position(world_position: Vector2) -> bool:
    """Indica si el bloque ocupa la casilla solicitada durante o después del deslizamiento."""
    var tolerance := 1.0
    if current_state == Enums.BlockState.LAUNCHED:
        if target_position.distance_to(world_position) < tolerance:
            return true
        if _slide_origin.distance_to(world_position) < tolerance:
            return true
        if _launch_direction != Vector2i.ZERO:
            var current_grid: Vector2i = GameHelpers.world_to_grid(_slide_origin)
            var end_grid: Vector2i = GameHelpers.world_to_grid(target_position)
            var check_grid: Vector2i = current_grid
            while check_grid != end_grid:
                check_grid += _launch_direction
                if GameHelpers.grid_to_world(check_grid).distance_to(world_position) < tolerance:
                    return true
    return target_position.distance_to(world_position) < tolerance


func _play_launch_feedback() -> void:
    if is_instance_valid(_feedback_tween):
        _feedback_tween.kill()
    scale = Vector2.ONE
    _feedback_tween = create_tween()
    _feedback_tween.tween_property(self, "scale", Vector2.ONE * 1.1, SLIDE_TIME * 0.5)
    _feedback_tween.tween_property(self, "scale", Vector2.ONE, SLIDE_TIME * 0.5)


func _play_destroy_feedback() -> void:
    if is_instance_valid(_feedback_tween):
        _feedback_tween.kill()
    _feedback_tween = create_tween()
    _feedback_tween.tween_property(self, "modulate:a", 0.0, SLIDE_TIME)

func _get_audio_manager() -> AudioManager:
    var tree := get_tree()
    if tree == null:
        return null
    var root := tree.root
    if root == null:
        return null
    return root.get_node_or_null("AudioManager") as AudioManager
