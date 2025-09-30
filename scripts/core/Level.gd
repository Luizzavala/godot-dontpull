extends Node2D
class_name Level

## Configura la escena de nivel y posiciona entidades sobre un grid definido por constantes.
const Consts = preload("res://scripts/utils/constants.gd")

@onready var tile_map: TileMap = %GroundTileMap
@onready var player: Player = %Player
@onready var enemy: Enemy = %Enemy
@onready var block: Block = %Block
@onready var hud: HUD = %HUD

func _ready() -> void:
    """Genera el tilemap base y alinea las entidades al grid."""
    _populate_tile_map()
    _align_entities()
    GameManager.start_level()


func _populate_tile_map() -> void:
    """Rellena el TileMap con un patrón sencillo de GRID_WIDTH x GRID_HEIGHT celdas."""
    tile_map.clear()
    for x in range(Consts.GRID_WIDTH):
        for y in range(Consts.GRID_HEIGHT):
            tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)


func _align_entities() -> void:
    """Reposiciona jugador, enemigo y bloque en el grid inicial."""
    var player_cell := Vector2i(1, 2)
    var block_cell := Vector2i(2, 2)
    var enemy_cell := Vector2i(3, 2)
    player.global_position = GameHelpers.grid_to_world(player_cell)
    player.target_position = player.global_position
    block.global_position = GameHelpers.grid_to_world(block_cell)
    block.target_position = block.global_position
    enemy.global_position = GameHelpers.grid_to_world(enemy_cell)
    enemy.target_position = enemy.global_position
    hud.offset = Vector2.ZERO
