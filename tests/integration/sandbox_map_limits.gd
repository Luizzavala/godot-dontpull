## SandboxMapLimits configura un grid pequeño para visualizar los bordes del mapa.
extends Node2D

const GameHelpers = preload("res://scripts/utils/helpers.gd")

@export var grid_size: Vector2i = Vector2i(5, 5)
@onready var tile_map: TileMap = %GroundTileMap
@onready var player: Player = %Player
@onready var block: Block = %Block
@onready var enemy: Enemy = %Enemy

func _ready() -> void:
    """Prepara un tablero compacto con posiciones iniciales seguras."""
    GameHelpers.set_map_bounds(Rect2i(Vector2i.ZERO, grid_size))
    _populate_tile_map()
    player.global_position = GameHelpers.grid_to_world(Vector2i(1, 1))
    player.target_position = player.global_position
    block.global_position = GameHelpers.grid_to_world(Vector2i(grid_size.x - 2, 1))
    block.target_position = block.global_position
    enemy.global_position = GameHelpers.grid_to_world(Vector2i(1, grid_size.y - 2))
    enemy.target_position = enemy.global_position

func _populate_tile_map() -> void:
    tile_map.clear()
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)
