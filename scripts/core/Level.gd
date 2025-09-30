## Level configura la escena de juego y posiciona entidades sobre un grid común.
extends Node2D
class_name Level

const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

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
    player.global_position = GameHelpers.grid_to_world(Consts.PLAYER_START)
    player.target_position = player.global_position
    block.global_position = GameHelpers.grid_to_world(Consts.BLOCK_START)
    block.target_position = block.global_position
    enemy.global_position = GameHelpers.grid_to_world(Consts.ENEMY_START)
    enemy.target_position = enemy.global_position
    hud.offset = Vector2.ZERO
