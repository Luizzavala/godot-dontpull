extends Node
class_name GameManager

##
# GameManager coordina el ciclo de vida del nivel, gestiona el grid y la
# interacción entre jugador, enemigos y bloques.
##

const TILE_SIZE := 64

enum MoveType { NONE, WALK, PUSH }

enum CellContent { EMPTY, PLAYER, ENEMY, BLOCK }

var grid_size: Vector2i = Vector2i(5, 5)
var grid_origin: Vector2 = Vector2.ZERO
var tile_map: TileMap
var hud: HUD
var player_ref: Player
var enemy_refs: Array = []
var block_refs: Array = []
var score: int = 0
var lives: int = 3
var level_active: bool = false

var _occupancy: Dictionary = {}
var _actor_cells: Dictionary = {}

##
# Configura referencias principales antes de iniciar el nivel.
#
# @param grid_size_ref Dimensiones del grid.
# @param tile_map_ref Referencia al TileMap que representa el suelo.
# @param hud_ref HUD encargado de mostrar puntuación y vidas.
##
func setup_level(grid_size_ref: Vector2i, tile_map_ref: TileMap, hud_ref: HUD) -> void:
    grid_size = grid_size_ref
    tile_map = tile_map_ref
    hud = hud_ref
    _occupancy.clear()
    _actor_cells.clear()
    enemy_refs.clear()
    block_refs.clear()
    level_active = false

##
# Inicia el nivel actual y sincroniza HUD con los valores vigentes.
##
func start_level() -> void:
    level_active = true
    if hud:
        hud.update_score(score)
        hud.update_lives(lives)

##
# Termina el nivel y muestra mensaje en HUD según resultado.
#
# @param victory Indica si el jugador completó el nivel.
##
func end_level(victory: bool) -> void:
    level_active = false
    if hud:
        var message := "Victoria" if victory else "Derrota"
        hud.show_message(message)

##
# Registra al jugador en el grid y almacena referencia global.
#
# @param player Nodo jugador.
# @param cell Posición inicial en el grid.
##
func register_player(player: Player, cell: Vector2i) -> void:
    player_ref = player
    _register_actor(player, cell)

##
# Registra un enemigo y lo añade al control del GameManager.
#
# @param enemy Nodo enemigo.
# @param cell Posición inicial en el grid.
##
func register_enemy(enemy: Enemy, cell: Vector2i) -> void:
    if not enemy_refs.has(enemy):
        enemy_refs.append(enemy)
    _register_actor(enemy, cell)

##
# Registra un bloque deslizante en el grid.
#
# @param block Nodo bloque.
# @param cell Posición inicial en el grid.
##
func register_block(block: Block, cell: Vector2i) -> void:
    if not block_refs.has(block):
        block_refs.append(block)
    _register_actor(block, cell)

##
# Devuelve la posición del jugador en coordenadas de grid.
##
func get_player_cell() -> Vector2i:
    if not player_ref:
        return Vector2i.ZERO
    return _actor_cells.get(player_ref, Vector2i.ZERO)

##
# Intenta mover al jugador en la dirección solicitada.
#
# @param direction Dirección en coordenadas enteras (Vector2i).
# @return Tipo de movimiento resultante.
##
func try_player_move(direction: Vector2i) -> MoveType:
    if not player_ref:
        return MoveType.NONE
    var current_cell: Vector2i = _actor_cells.get(player_ref, Vector2i.ZERO)
    var target_cell: Vector2i = current_cell + direction
    if not _is_cell_inside(target_cell):
        return MoveType.NONE
    if not _occupancy.has(target_cell):
        _reserve_actor_move(player_ref, target_cell)
        return MoveType.WALK
    var occupant := _occupancy[target_cell]
    if occupant is Block and _try_start_push_block(occupant, direction):
        _reserve_actor_move(player_ref, target_cell)
        return MoveType.PUSH
    return MoveType.NONE

##
# Intenta mover a un enemigo en el grid.
#
# @param enemy Nodo enemigo.
# @param direction Dirección de desplazamiento.
# @return `true` si el movimiento es válido.
##
func try_enemy_move(enemy: Enemy, direction: Vector2i) -> bool:
    if not enemy_refs.has(enemy):
        return false
    var current_cell: Vector2i = _actor_cells.get(enemy, Vector2i.ZERO)
    var target_cell: Vector2i = current_cell + direction
    if not _is_cell_inside(target_cell):
        return false
    if _occupancy.has(target_cell):
        return false
    _reserve_actor_move(enemy, target_cell)
    return true

##
# Solicita al bloque continuar deslizándose a la siguiente celda.
#
# @param block Nodo bloque deslizante.
# @param next_cell Celda candidata.
# @return `true` si el bloque puede ocupar la celda.
##
func can_block_occupy(block: Block, next_cell: Vector2i) -> bool:
    if not _is_cell_inside(next_cell):
        return false
    if not _occupancy.has(next_cell):
        return true
    var occupant := _occupancy[next_cell]
    if occupant is Enemy:
        _handle_enemy_hit(occupant)
        return true
    return false

##
# Registra la nueva celda de un bloque mientras se desliza.
#
# @param block Nodo bloque.
# @param cell Celda actualizada.
##
func notify_block_cell(block: Block, cell: Vector2i) -> void:
    _reserve_actor_move(block, cell)

##
# Notifica la destrucción de un bloque (por ejemplo al impactar).
##
func notify_block_destroyed(block: Block) -> void:
    if _actor_cells.has(block):
        var cell: Vector2i = _actor_cells[block]
        _occupancy.erase(cell)
        _actor_cells.erase(block)

##
# Convierte coordenadas de grid a mundo.
##
func grid_to_world(cell: Vector2i) -> Vector2:
    return Vector2(cell) * TILE_SIZE + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)

##
# Convierte coordenadas de mundo a grid.
##
func world_to_grid(position: Vector2) -> Vector2i:
    var offset := position - Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
    return Vector2i(round(offset.x / TILE_SIZE), round(offset.y / TILE_SIZE))

##
# Devuelve el tamaño actual del grid.
##
func get_grid_size() -> Vector2i:
    return grid_size

##
# Aplica daño al jugador y gestiona vidas restantes.
##
func on_player_defeated() -> void:
    if not level_active:
        return
    lives = max(lives - 1, 0)
    if hud:
        hud.update_lives(lives)
    if lives <= 0:
        end_level(false)

##
# Incrementa el marcador global y actualiza HUD.
#
# @param amount Puntos a sumar.
##
func add_score(amount: int) -> void:
    score += amount
    if hud:
        hud.update_score(score)

##
# Devuelve el contenido de una celda para depuración.
##
func get_cell_content(cell: Vector2i) -> CellContent:
    if not _is_cell_inside(cell):
        return CellContent.EMPTY
    if not _occupancy.has(cell):
        return CellContent.EMPTY
    var occupant := _occupancy[cell]
    if occupant == player_ref:
        return CellContent.PLAYER
    if occupant is Enemy:
        return CellContent.ENEMY
    if occupant is Block:
        return CellContent.BLOCK
    return CellContent.EMPTY

func _register_actor(actor: Node, cell: Vector2i) -> void:
    _occupancy[cell] = actor
    _actor_cells[actor] = cell

func _reserve_actor_move(actor: Node, target_cell: Vector2i) -> void:
    var previous_cell := _actor_cells.get(actor)
    if previous_cell != null:
        _occupancy.erase(previous_cell)
    _occupancy[target_cell] = actor
    _actor_cells[actor] = target_cell

func _try_start_push_block(block: Block, direction: Vector2i) -> bool:
    var block_cell: Vector2i = _actor_cells.get(block, Vector2i.ZERO)
    var next_cell: Vector2i = block_cell + direction
    if not can_block_occupy(block, next_cell):
        return false
    if block.begin_slide(direction):
        _occupancy.erase(block_cell)
        _actor_cells.erase(block)
        return true
    return false

func _handle_enemy_hit(enemy: Enemy) -> void:
    if enemy_refs.has(enemy):
        enemy.on_defeated()
        var cell: Vector2i = _actor_cells.get(enemy, Vector2i.ZERO)
        _occupancy.erase(cell)
        _actor_cells.erase(enemy)
        enemy_refs.erase(enemy)
        add_score(100)

func _is_cell_inside(cell: Vector2i) -> bool:
    return cell.x >= grid_origin.x and cell.y >= grid_origin.y and cell.x < grid_origin.x + grid_size.x and cell.y < grid_origin.y + grid_size.y
